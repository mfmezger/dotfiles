# Decision model server on a GPU VM

[`scripts/decision_gpu_server.sh`](../scripts/decision_gpu_server.sh) turns a fresh Ubuntu GPU VM into a
[System One](https://docs.typesafe.ai/api) decision API serving
[Decision-2.0-Lux-9B](https://huggingface.co/vllm-sr/Decision-2.0-Lux-9B). Lux takes a state (text or JSON)
plus typed questions (`choice`, `noul`, `score`) and returns a probability for every answer, without
generating text.

Tested on a STACKIT `n2.14d.g1` (1x NVIDIA L40S 48 GB, Ubuntu 26.04, kernel 7.0).

## What it installs

| Step | What |
| --- | --- |
| Driver | NVIDIA `595-server` with prebuilt open kernel modules (no DKMS); loaded live, reboots once only if that fails |
| Containers | Docker Engine (download.docker.com) and the NVIDIA Container Toolkit |
| Image | `python:3.12-slim-trixie` + torch 2.13 (CUDA 13.0), transformers 5.17, flash-linear-attention, FastAPI |
| Model | Downloaded once into `/opt/decision/data`, pinned to a commit (the model ships `trust_remote_code`) |
| Service | `docker compose` in `/opt/decision`, `restart: unless-stopped`, healthcheck, bound to `127.0.0.1:8000` |

Lux is not a vLLM model despite the `vllm-sr` name (vLLM Semantic Router). It runs through Transformers,
and the script wraps it in a small FastAPI server.

## Usage

`gpu` is an SSH host alias for the VM (`~/.ssh/config`).

```bash
scp scripts/decision_gpu_server.sh gpu:
ssh gpu 'sudo bash decision_gpu_server.sh'   # ~15 min on a fresh VM; safe to re-run
```

If the script reboots for the driver, run it again after the VM is back. For a long first run, start it
inside `tmux` so a dropped SSH connection does not interrupt apt. To download with a Hugging Face token
(optional, avoids anonymous rate limits), pass it through `sudo`:
`ssh gpu 'sudo HF_TOKEN=hf_... bash decision_gpu_server.sh'`.

The API only listens on localhost. Reach it through an SSH tunnel:

```bash
ssh -N -L 8000:127.0.0.1:8000 gpu

curl localhost:8000/health
curl localhost:8000/v1/systemone -H 'content-type: application/json' -d '{
  "model": "Decision-2.0-Lux-9B",
  "state": "The order arrived damaged yesterday. The customer has a receipt and asks for a replacement today.",
  "questions": {
    "route":   {"type": "choice", "instructions": "Which team?",
                "criteria": {"returns": "Refunds and damaged deliveries", "billing": "Payments", "technical": "Product faults"}},
    "receipt": {"type": "noul",   "instructions": "Does the customer have a receipt?"},
    "urgency": {"type": "score",  "instructions": "How urgent?", "criteria": ["Routine", "Soon", "Today"]}
  }}'
```

## Operations

```bash
ssh gpu 'sudo docker logs -f decision'                            # logs (load, warm-up, per-request timing)
ssh gpu 'sudo docker restart decision'                            # restart (~2 min until healthy)
```

The script is the source of truth: it rewrites `/opt/decision/{Dockerfile,server.py,compose.yaml}` on every
run, so edits made on the VM are lost on the next run. Change the heredocs in the script instead and re-run it.
To switch models, change `MODEL_ID` / `MODEL_REVISION` at the top of the script and re-run it.

## Measured on the L40S

| Request | Model time |
| --- | --- |
| 1 question, short state | ~50 ms |
| 3 questions, ~5k tokens | ~600 ms |

GPU memory is ~18.7 GB. Startup, including loading and warm-up, takes ~2 minutes. The model card's 18 ms
comes from AMD MI300 GPUs, where the runtime enables HIP graphs and fused kernels; on NVIDIA it runs the
eager path. `Decision-2.0-Vega-27B` does not fit in 48 GB.
