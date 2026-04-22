#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Starting Arch Linux / CachyOS Installation from $DOTFILES_DIR <<<"

source "$DOTFILES_DIR/scripts/common.sh"

if ! command -v paru &>/dev/null; then
    echo ">>> paru is required but not installed <<<"
    echo ">>> Install paru first, then re-run this script <<<"
    exit 1
fi

# ==============================================================================
# 1. System Update
# ==============================================================================
echo ">>> Updating system packages <<<"
paru -Syyu --noconfirm

# ============================================================================== 
# 2. Install Core Packages via Paru
# ============================================================================== 
echo ">>> Installing core packages <<<"
paru -S --needed --noconfirm \
    zsh \
    zellij \
    stow \
    atuin \
    eza \
    zoxide \
    docker \
    docker-compose \
    btop \
    bat \
    onefetch \
    fastfetch \
    neovim \
    dust \
    tokei \
    tree \
    git-delta \
    github-cli \
    ghostty \
    ttf-cascadia-code-nerd \
    ttf-cascadia-mono-nerd \
    xclip \
    zed \
    go \
    scrot \
    dunst \
    hyprland \
    hypridle \
    hyprlock \
    waybar \
    xdg-desktop-portal-hyprland \
    qt5-wayland \
    qt6-wayland \
    rofi-wayland \
    rofi-calc \
    wlogout \
    grim \
    slurp \
    wl-clipboard \
    brightnessctl \
    playerctl \
    thunar \
    pavucontrol \
    power-profiles-daemon \
    polkit-gnome \
    gnome-keyring

# Install the packaged Powerlevel10k when available to avoid AUR conflicts
POWERLEVEL10K_INSTALLED_FROM_REPO=0
if paru -Q zsh-theme-powerlevel10k &>/dev/null; then
    echo ">>> zsh-theme-powerlevel10k already installed <<<"
    POWERLEVEL10K_INSTALLED_FROM_REPO=1
elif paru -Si zsh-theme-powerlevel10k &>/dev/null; then
    echo ">>> Installing zsh-theme-powerlevel10k from repos via paru <<<"
    paru -S --needed --noconfirm zsh-theme-powerlevel10k
    POWERLEVEL10K_INSTALLED_FROM_REPO=1
fi

# ============================================================================== 
# 3. Install Extra Packages via Paru
# ============================================================================== 
echo ">>> Installing extra packages via paru <<<"

AUR_PACKAGES=(
    visual-studio-code-bin
    brave-bin
    ekphos-bin
    zsh-abbr
    discord
    witr-bin
    cliphist
)

if [ "$POWERLEVEL10K_INSTALLED_FROM_REPO" -eq 0 ]; then
    AUR_PACKAGES+=(zsh-theme-powerlevel10k-git)
fi

paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# ==============================================================================
# 4. Install Personal Applications (Optional)
# ==============================================================================
echo ""
read -p ">>> Do you want to install personal packages (Obsidian, Steam, etc.)? (y/N) " -n 1 -r
echo # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Enable multilib repository for Steam (requires 32-bit libraries)
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo ">>> Enabling multilib repository for Steam <<<"
        sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
        paru -Sy --noconfirm
    else
        echo ">>> multilib repository already enabled <<<"
    fi

    echo ">>> Installing personal packages via paru <<<"
    paru -S --needed --noconfirm \
        qbittorrent \
        obsidian \
        steam
else
    echo ">>> Skipping personal packages <<<"
fi

# ==============================================================================
# 5. GPU Support: NVIDIA & CUDA (Optional)
# ==============================================================================
echo ""
read -p ">>> Do you want to install NVIDIA drivers and CUDA toolkit? (y/N) " -n 1 -r
echo # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if paru -Qq | grep -Eq '^(linux-cachyos.*nvidia|linux-cachyos.*nvidia-open|nvidia-dkms|nvidia-open-dkms|nvidia-open|nvidia)$'; then
        echo ">>> Existing NVIDIA driver stack detected, skipping driver installation <<<"
    else
        echo ">>> Installing NVIDIA drivers via distro tooling when available <<<"
        # nvidia-inst exists on some Arch-based distros and picks a suitable stack.
        if command -v nvidia-inst &>/dev/null; then
            nvidia-inst
        else
            echo ">>> nvidia-inst not found, installing generic nvidia packages <<<"
            paru -S --needed --noconfirm nvidia nvidia-utils nvidia-settings
        fi
    fi

    echo ">>> Installing CUDA toolkit <<<"
    paru -S --needed --noconfirm cuda

    echo ">>> Installing cuSPARSELt library <<<"
    paru -S --needed --noconfirm cusparselt

    echo ">>> Installing NVIDIA Container Toolkit for Docker <<<"
    paru -S --needed --noconfirm nvidia-container-toolkit

    # Configure Docker to use NVIDIA runtime
    echo ">>> Configuring Docker for NVIDIA GPU support <<<"
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker

    echo ">>> CUDA installed! The following paths have been added to your .zshrc: <<<"
    echo ">>> A reboot is recommended after NVIDIA driver installation. <<<"
else
    echo ">>> Skipping NVIDIA/CUDA installation <<<"
fi

# ==============================================================================
# 6. Install Oh My Zsh & Plugins
# ==============================================================================
echo ">>> Installing Oh My Zsh <<<"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    export RUNZSH=no
    export CHSH=no
    export KEEP_ZSHRC=yes
    export ZSH="$HOME/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo ">>> Oh My Zsh already installed <<<"
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo ">>> Installing zsh-autosuggestions <<<"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo ">>> zsh-autosuggestions already installed <<<"
fi

echo ">>> Installing zsh-syntax-highlighting <<<"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo ">>> zsh-syntax-highlighting already installed <<<"
fi

echo ">>> Installing zsh-autosuggestions-abbreviations-strategy <<<"
if [ ! -d "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy" ]; then
    git clone https://github.com/olets/zsh-autosuggestions-abbreviations-strategy.git \
        "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy"
else
    echo ">>> zsh-autosuggestions-abbreviations-strategy already installed <<<"
fi

# ==============================================================================
# 7. Install Python Tools (uv & commitizen)
# ==============================================================================
echo ">>> Installing uv <<<"
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo ">>> uv already installed <<<"
fi

# Ensure uv is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# 8. Install Rust Toolchain (rustup)
# ==============================================================================
echo ">>> Installing rustup <<<"
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
else
    echo ">>> rustup already installed <<<"
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

if ! cargo --version &>/dev/null; then
    echo ">>> Configuring default Rust toolchain (stable) <<<"
    rustup default stable
else
    echo ">>> Rust toolchain already configured <<<"
fi

echo ">>> Installing commitizen via uv <<<"
uv tool install commitizen

# ==============================================================================
# 9. Generate Shell Completions (Pre-cached for faster shell startup)
# ==============================================================================
echo ">>> Generating shell completions <<<"
COMPLETIONS_DIR="$HOME/.local/share/zsh/completions"
mkdir -p "$COMPLETIONS_DIR"

# Generate uv completions
if command -v uv &>/dev/null; then
    echo ">>> Generating uv/uvx completions <<<"
    uv generate-shell-completion zsh >"$COMPLETIONS_DIR/_uv"
    uvx --generate-shell-completion zsh >"$COMPLETIONS_DIR/_uvx"
fi

# Generate atuin init script
if command -v atuin &>/dev/null; then
    echo ">>> Generating atuin completions <<<"
    atuin init zsh >"$COMPLETIONS_DIR/atuin-init.zsh"
    echo ">>> Importing shell history into atuin <<<"
    atuin import auto || {
        echo ">>> Warning: Failed to import shell history into atuin."
        echo ">>> Please check atuin logs or run 'atuin import auto' manually."
    }
fi

# Generate GitHub CLI completions
if command -v gh &>/dev/null; then
    echo ">>> Generating gh completions <<<"
    gh completion -s zsh >"$COMPLETIONS_DIR/_gh"
fi

# Generate Docker completions
if command -v docker &>/dev/null; then
    echo ">>> Generating docker completions <<<"
    docker completion zsh >"$COMPLETIONS_DIR/_docker"
fi

# Generate kubectl completions (if installed)
if command -v kubectl &>/dev/null; then
    echo ">>> Generating kubectl completions <<<"
    kubectl completion zsh >"$COMPLETIONS_DIR/_kubectl"
fi

# Generate helm completions (if installed)
if command -v helm &>/dev/null; then
    echo ">>> Generating helm completions <<<"
    helm completion zsh >"$COMPLETIONS_DIR/_helm"
fi

# ==============================================================================
# 10. Configure Docker
# ==============================================================================
echo ">>> Configuring Docker <<<"
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker "$USER"

# ==============================================================================
# 11. Security: ClamAV Antivirus
# ==============================================================================
echo ">>> Setting up ClamAV antivirus <<<"
paru -S --needed --noconfirm clamav
sudo systemctl enable clamav-freshclam
sudo freshclam || echo ">>> Warning: freshclam update failed, will retry on next boot <<<"

# ==============================================================================
# 12. Security: Firewall (UFW)
# ==============================================================================
echo ">>> Configuring UFW firewall <<<"
paru -S --needed --noconfirm ufw

sudo systemctl enable ufw.service
sudo systemctl start ufw.service

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

# ==============================================================================
# 13. Security: Application Firewall (OpenSnitch)
# ==============================================================================
echo ">>> Setting up OpenSnitch application firewall <<<"
paru -S --needed --noconfirm opensnitch
sudo systemctl enable --now opensnitchd

# ==============================================================================
# 14. Link Dotfiles
# ==============================================================================
echo ">>> Linking dotfiles <<<"
cd "$DOTFILES_DIR"

# Backup common conflict files
backup_if_exists ".zshrc"
backup_if_exists ".p10k.zsh"
backup_if_exists ".gitconfig"
backup_if_exists ".config/nvim"
backup_if_exists ".config/yazi"
backup_if_exists ".config/zellij"
backup_if_exists ".config/hypr"
backup_if_exists ".config/ghostty"
backup_if_exists ".config/ekphos"
mkdir -p "$HOME/Documents/ekphos"
backup_if_exists ".config/zed"
backup_if_exists ".config/dunst"
backup_if_exists ".config/waybar"
backup_if_exists ".config/rofi"
backup_if_exists ".config/gtk-3.0"
backup_if_exists ".config/gtk-4.0"
backup_if_exists ".gtkrc-2.0"

# Run stow
stow zsh nvim yazi zellij git ghostty ekphos zed dunst hypr waybar rofi gtk

# ==============================================================================
# 15. Set Default Shell
# ==============================================================================
echo ">>> Setting zsh as default shell <<<"
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo ">>> Installation successfully completed! <<<"
echo ""
echo "Please log out and log back in to:"
echo "  - Use zsh as your default shell"
echo "  - Apply Docker group membership"
