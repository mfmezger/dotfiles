#!/bin/bash
# Install Docker Engine and Docker Compose on Ubuntu.
set -eo pipefail

sudo apt update
sudo apt install -y ca-certificates curl

# APT reads ASCII-armored keys directly; no gpg binary is needed.
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
. /etc/os-release
ARCH="$(dpkg --print-architecture)"
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unzip
docker compose version

TARGET_USER="$(id -un)"
if [[ $EUID -eq 0 && -n ${SUDO_USER:-} ]]; then
    TARGET_USER="$SUDO_USER"
fi
if [[ $TARGET_USER != root ]]; then
    sudo usermod -aG docker "$TARGET_USER"
    echo "Done. Log out and back in for the docker group to take effect."
else
    echo "Done. No non-root user specified; docker group unchanged."
fi
