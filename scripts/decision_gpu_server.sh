#!/bin/bash
# Decision-2.0-Lux-9B as a System One API (POST /v1/systemone) on an NVIDIA GPU VM.
#
#   Target : Ubuntu 26.04, 1x NVIDIA L40S (STACKIT n2.14d.g1)
#   Stack  : NVIDIA 595-server-open (prebuilt kernel modules) -> Docker + NVIDIA Container Toolkit
#            -> Python 3.12 / torch 2.13 cu130 / transformers 5.17 / flash-linear-attention -> FastAPI
#   Access : bound to 127.0.0.1:8000 only; use an SSH tunnel:  ssh -N -L 8000:127.0.0.1:8000 gpu
#
# Idempotent: every step checks its own state, so re-running is safe and fast.
# If the driver cannot be loaded live, the script reboots once; run it again afterwards.
#
#   sudo bash decision_gpu_server.sh
set -euo pipefail

# ---------------------------------------------------------------- settings
DRIVER=595-server # NVIDIA server branch, open kernel modules
MODEL_ID=vllm-sr/Decision-2.0-Lux-9B
MODEL_REVISION=78bf3c03d9147aeb30b641edfe0e30ed04887ca5 # pinned commit (model code runs with trust_remote_code)
APP_DIR=/opt/decision
IMAGE=decision-server:lux2
PORT=8000
APP_UID=1000 # must match the uid of the 'app' user in the Dockerfile below

export DEBIAN_FRONTEND=noninteractive
APT=(apt-get -y -q -o DPkg::Lock::Timeout=600 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() {
    printf '\n\033[1;31mERROR: %s\033[0m\n' "$*" >&2
    exit 1
}
gpu_ok() { nvidia-smi -L > /dev/null 2>&1; }

[[ $EUID -eq 0 ]] || die "run as root: sudo bash $0"
. /etc/os-release
ARCH=$(dpkg --print-architecture)

# ---------------------------------------------------------------- 1. NVIDIA driver
install_driver() {
    # linux-modules-nvidia-*-generic tracks future kernel updates; the exact one matches the running kernel.
    local PACKAGES=(
        "linux-modules-nvidia-${DRIVER}-open-generic"
        "linux-modules-nvidia-${DRIVER}-open-$(uname -r)"
        "nvidia-headless-no-dkms-${DRIVER}-open"
        "nvidia-utils-${DRIVER}"
    )
    local PKG MISSING=0
    for PKG in "${PACKAGES[@]}"; do
        [[ $(dpkg-query -W -f='${db:Status-Status}' "$PKG" 2> /dev/null) == installed ]] || MISSING=1
    done
    if ((MISSING == 0)) && [[ -f /etc/modprobe.d/blacklist-nouveau.conf ]]; then
        log "NVIDIA ${DRIVER} driver packages already installed"
        return
    fi
    log "Installing NVIDIA ${DRIVER} (open kernel modules, prebuilt for $(uname -r))"
    "${APT[@]}" update
    "${APT[@]}" install --no-install-recommends "${PACKAGES[@]}"
    printf 'blacklist nouveau\noptions nouveau modeset=0\n' > /etc/modprobe.d/blacklist-nouveau.conf
    update-initramfs -u
}

load_driver() {
    if ! gpu_ok; then
        log "Loading the NVIDIA driver without a reboot"
        modprobe -r nouveau 2> /dev/null || true
        modprobe nvidia 2> /dev/null || true
    fi
    local marker=/var/lib/decision-setup/driver-boot-id
    if ! gpu_ok; then
        mkdir -p "$(dirname "$marker")"
        if [[ -f $marker && $(< "$marker") != $(< /proc/sys/kernel/random/boot_id) ]]; then
            die "rebooted after the driver install, but nvidia-smi still fails; check: dmesg | grep -i nvidia"
        fi
        cat /proc/sys/kernel/random/boot_id > "$marker"
        log "Driver needs a reboot. Rebooting now; run this script again afterwards."
        systemctl reboot
        exit 0
    fi
    rm -f "$marker"
    systemctl enable --now nvidia-persistenced > /dev/null 2>&1 || true
    log "GPU: $(nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader)"
}

# ---------------------------------------------------------------- 2. Docker
install_docker() {
    if command -v docker > /dev/null && docker compose version > /dev/null 2>&1; then
        log "Docker already installed: $(docker --version)"
    else
        log "Installing Docker Engine from download.docker.com"
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
            > /etc/apt/sources.list.d/docker.list
        "${APT[@]}" update
        "${APT[@]}" install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
    if [[ -n ${SUDO_USER:-} ]] && ! id -nG "$SUDO_USER" | grep -qw docker; then
        usermod -aG docker "$SUDO_USER" # docker without sudo from the next login on
    fi
}

# ---------------------------------------------------------------- 3. NVIDIA Container Toolkit
install_container_toolkit() {
    if ! command -v nvidia-ctk > /dev/null; then
        log "Installing the NVIDIA Container Toolkit"
        curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey -o /usr/share/keyrings/nvidia-container-toolkit.asc
        curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit.asc] https://#' \
                > /etc/apt/sources.list.d/nvidia-container-toolkit.list
        "${APT[@]}" update
        "${APT[@]}" install nvidia-container-toolkit
    fi
    if ! grep -qs '"nvidia"' /etc/docker/daemon.json; then
        log "Registering the NVIDIA runtime with Docker"
        nvidia-ctk runtime configure --runtime=docker
        systemctl restart docker
    fi
}

# ---------------------------------------------------------------- 4. app files
write_app() {
    log "Writing ${APP_DIR}"
    install -d -m 0755 "$APP_DIR"
    install -d -o "$APP_UID" -g "$APP_UID" "$APP_DIR/data"

    cat > "$APP_DIR/Dockerfile" << 'EOF'
# syntax=docker/dockerfile:1
FROM python:3.12-slim-trixie
COPY --from=ghcr.io/astral-sh/uv:0.12.23 /uv /usr/local/bin/uv

# gcc + libc headers: Triton (used by flash-linear-attention) compiles a small launcher at runtime.
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc libc6-dev \
 && rm -rf /var/lib/apt/lists/*

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system --torch-backend=cu130 \
      torch==2.13.0 \
      transformers==5.17.0 \
      flash-linear-attention==0.5.2 \
      peft==0.21.2 \
      fastapi==0.142.4 \
      uvicorn==0.54.0

# uid 1000 = APP_UID in the setup script (owner of the mounted /data)
RUN useradd --create-home --uid 1000 app
WORKDIR /app
COPY server.py .
USER app
ENV HF_HOME=/data/hf \
    TRITON_CACHE_DIR=/data/triton \
    HF_HUB_OFFLINE=1 \
    HF_HUB_DISABLE_TELEMETRY=1 \
    PYTHONUNBUFFERED=1
EXPOSE 8000
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000", "--timeout-graceful-shutdown", "10"]
EOF

    cat > "$APP_DIR/server.py" << 'EOF'
"""System One server (POST /v1/systemone) for one Decision 2.0 model on one GPU.

Request and response bodies are the model's own system_one():
  in : {"model": "...", "state": <text | JSON>, "questions": {id: {"type": "choice"|"noul"|"score", ...}}}
  out: {"model": "...", "answers": {id: {...}}, "usage": {"input_tokens": n, "output_tokens": 0}}
The questions of one request run as one batch; requests run one at a time on the GPU.
"""

import asyncio
import logging
import os
import threading
import time
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

MODEL_ID = os.environ["MODEL_ID"]
MODEL_REVISION = os.environ["MODEL_REVISION"]
MAX_QUESTIONS = int(os.environ.get("MAX_QUESTIONS", "64"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
log = logging.getLogger("decision")

_model: Any = None
_ready = False  # uvicorn listens only after the lifespan load; the 503s guard direct/embedded use
_gpu = threading.Lock()

_ROUTE = {
    "type": "choice",
    "instructions": "Which team should handle this request?",
    "criteria": {
        "returns": "Refunds, replacements and damaged deliveries",
        "billing": "Payments, invoices and charges",
        "technical": "Product setup and faults",
    },
}
WARMUP = {
    "short": {"state": "Customer requests a refund.", "questions": {"route": _ROUTE}},
    "long": {
        "state": "Ticket: " + "My order arrived damaged and I need a replacement before the weekend. " * 120,
        "questions": {
            "route": _ROUTE,
            "receipt": {"type": "noul", "instructions": "Does the customer mention a receipt?"},
            "urgency": {"type": "score", "instructions": "How urgent is this?", "criteria": ["Routine", "Soon", "Today"]},
        },
    },
}


def _error(status: int, message: str) -> JSONResponse:
    return JSONResponse(status_code=status, content={"error": {"message": message, "type": "invalid_request_error"}})


def _run(state: Any, questions: dict) -> dict:
    with _gpu:
        return _model.system_one(state=state, questions=questions)


def _load() -> None:
    global _model, _ready
    import torch
    from transformers import AutoModel
    from transformers.models.qwen3_5 import modeling_qwen3_5

    start = time.perf_counter()
    _model = AutoModel.from_pretrained(MODEL_ID, revision=MODEL_REVISION, trust_remote_code=True)
    log.info(
        "loaded %s@%s in %.0f s on %s (%.1f GiB allocated)",
        MODEL_ID, MODEL_REVISION[:8], time.perf_counter() - start,
        torch.cuda.get_device_name(0), torch.cuda.memory_allocated() / 2**30,
    )
    log.info("gated-delta kernel: %s", getattr(modeling_qwen3_5.torch_chunk_gated_delta_rule, "__module__", "?"))
    for name, request in WARMUP.items():
        for _ in range(3):
            began = time.perf_counter()
            result = _run(request["state"], request["questions"])
        log.info("warm-up %s: %.0f ms, %d tokens", name, (time.perf_counter() - began) * 1e3, result["usage"]["input_tokens"])
    _ready = True


@asynccontextmanager
async def lifespan(_: FastAPI):
    await asyncio.to_thread(_load)
    yield


app = FastAPI(title="Decision System One", lifespan=lifespan)


@app.post("/v1/systemone")
async def systemone(request: Request) -> JSONResponse:
    if not _ready:
        return _error(503, "model is loading")
    try:
        body = await request.json()
    except ValueError:
        return _error(400, "body must be JSON")
    if not isinstance(body, dict) or "state" not in body:
        return _error(400, "state is required")
    questions = body.get("questions")
    if not isinstance(questions, dict) or not questions:
        return _error(400, "questions must be a non-empty object")
    if len(questions) > MAX_QUESTIONS:
        return _error(400, f"at most {MAX_QUESTIONS} questions per request")
    began = time.perf_counter()
    try:
        result = await asyncio.to_thread(_run, body["state"], questions)
    except (ValueError, TypeError) as exc:
        return _error(400, str(exc))
    elapsed = (time.perf_counter() - began) * 1e3
    log.info("systemone: %d questions, %d tokens, %.1f ms", len(questions), result["usage"]["input_tokens"], elapsed)
    return JSONResponse(result, headers={"Server-Timing": f"model;dur={elapsed:.1f}"})


@app.get("/v1/models")
async def models() -> dict:
    name = _model.model_name if _model is not None else MODEL_ID.split("/")[-1]
    return {"object": "list", "data": [{"id": name, "object": "model", "owned_by": "vllm-sr"}]}


@app.get("/health")
async def health() -> JSONResponse:
    if not _ready:
        return JSONResponse(status_code=503, content={"status": "loading"})
    return JSONResponse({"status": "ok", "model": MODEL_ID, "revision": MODEL_REVISION})
EOF

    cat > "$APP_DIR/compose.yaml" << EOF
services:
  decision:
    build: .
    image: ${IMAGE}
    container_name: decision
    restart: unless-stopped
    ports:
      - "127.0.0.1:${PORT}:8000"     # local only; reach it through an SSH tunnel
    environment:
      MODEL_ID: ${MODEL_ID}
      MODEL_REVISION: ${MODEL_REVISION}
    volumes:
      - ./data:/data                 # HF cache (model) + Triton kernel cache
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    security_opt:
      - no-new-privileges:true
    cap_drop: [ALL]
    logging:
      driver: json-file
      options: { max-size: 10m, max-file: "3" }
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3)"]
      interval: 15s
      timeout: 5s
      retries: 3
      start_period: 20m
EOF
}

# ---------------------------------------------------------------- 5. image + model
build_image() {
    log "Building ${IMAGE}"
    docker compose --project-directory "$APP_DIR" build
}

download_model() {
    log "Downloading ${MODEL_ID}@${MODEL_REVISION:0:8} into ${APP_DIR}/data/hf (skips files already present)"
    docker run --rm \
        -v "$APP_DIR/data:/data" \
        -e HF_HUB_OFFLINE=0 -e HF_XET_HIGH_PERFORMANCE=1 ${HF_TOKEN:+-e HF_TOKEN} \
        "$IMAGE" python -c "
from huggingface_hub import snapshot_download
print(snapshot_download('${MODEL_ID}', revision='${MODEL_REVISION}'))"
}

# ---------------------------------------------------------------- 6. run + verify
start_service() {
    log "Starting the service"
    docker compose --project-directory "$APP_DIR" up -d
    local deadline=$((SECONDS + 1500)) status
    while :; do
        status=$(docker inspect -f '{{.State.Health.Status}}' decision 2> /dev/null || echo missing)
        [[ $status == healthy ]] && break
        if [[ $status == unhealthy ]] || [[ $(docker inspect -f '{{.RestartCount}}' decision) -gt 0 ]] || ((SECONDS > deadline)); then
            docker logs --tail 80 decision
            die "service did not become healthy (status: ${status})"
        fi
        sleep 10
    done
    docker logs decision 2>&1 | grep -E "loaded|gated-delta|warm-up" || true
}

smoke_test() {
    log "Smoke test"
    curl -fsS "http://127.0.0.1:${PORT}/v1/systemone" -H 'content-type: application/json' -d '{
    "model": "Decision-2.0-Lux-9B",
    "state": "The order arrived damaged yesterday. The customer has a receipt and asks for a replacement today.",
    "questions": {
      "route":   {"type": "choice", "instructions": "Which team should handle this request?",
                  "criteria": {"returns": "Refunds, replacements and damaged deliveries",
                               "billing": "Payments, invoices and charges", "technical": "Product setup and faults"}},
      "receipt": {"type": "noul", "instructions": "Does the customer have a receipt?"},
      "urgency": {"type": "score", "instructions": "How urgent is this request?", "criteria": ["Routine", "Soon", "Today"]}
    }}' | python3 -m json.tool
}

main() {
    install_driver
    install_docker
    install_container_toolkit
    write_app
    build_image # no GPU needed: runs before a possible reboot
    download_model
    load_driver # live load, or reboot once (then re-run)
    start_service
    smoke_test
    log "Done. From your Mac:  ssh -N -L ${PORT}:127.0.0.1:${PORT} gpu   then   curl localhost:${PORT}/health"
}

main "$@"
