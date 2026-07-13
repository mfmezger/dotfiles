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
paru -Syu --noconfirm

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
    go-task \
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
    walker \
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
elif paru --repo -Si zsh-theme-powerlevel10k &>/dev/null; then
    echo ">>> Installing zsh-theme-powerlevel10k from repos via paru <<<"
    paru --repo -S --needed --noconfirm zsh-theme-powerlevel10k
    POWERLEVEL10K_INSTALLED_FROM_REPO=1
fi

# ==============================================================================
# 3. Install Extra Packages via Paru
# ==============================================================================
echo ">>> Installing extra packages via paru <<<"

AUR_PACKAGES=(
    visual-studio-code-bin
    brave-bin
    zen-browser-bin
    zsh-abbr
    hunk-bin
    discord
    witr-bin
    cliphist
    elephant-bin
    elephant-desktopapplications-bin
    elephant-calc-bin
    elephant-runner-bin
    elephant-websearch-bin
    elephant-clipboard-bin
    elephant-providerlist-bin
    elephant-windows-bin
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
        paru -Syu --noconfirm
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
install_omz

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

ensure_repo "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
    https://github.com/zsh-users/zsh-autosuggestions
ensure_repo "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
    https://github.com/zsh-users/zsh-syntax-highlighting.git
ensure_repo "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy" \
    https://github.com/olets/zsh-autosuggestions-abbreviations-strategy.git

# ==============================================================================
# 7. Install Python Tools (uv & commitizen)
# ==============================================================================
ensure_tool uv "uv" 'curl -LsSf https://astral.sh/uv/install.sh | sh'

# Ensure uv is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# 8. Install Rust Toolchain (rustup)
# ==============================================================================
ensure_tool rustup "rustup" \
    "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

if ! cargo --version &>/dev/null; then
    echo ">>> Configuring default Rust toolchain (stable) <<<"
    rustup default stable
else
    echo ">>> Rust toolchain already configured <<<"
fi

ensure_tool ekphos "ekphos" "cargo install ekphos --locked"

echo ">>> Installing commitizen via uv <<<"
uv tool install commitizen

# ==============================================================================
# 9. Generate Shell Completions (Pre-cached for faster shell startup)
# ==============================================================================
gen_completions \
    'uv:uv generate-shell-completion zsh > "$COMPLETIONS_DIR/_uv"; uvx --generate-shell-completion zsh > "$COMPLETIONS_DIR/_uvx"' \
    'atuin:atuin init zsh > "$COMPLETIONS_DIR/atuin-init.zsh"' \
    'gh:gh completion -s zsh > "$COMPLETIONS_DIR/_gh"' \
    'docker:docker completion zsh > "$COMPLETIONS_DIR/_docker"' \
    'kubectl:kubectl completion zsh > "$COMPLETIONS_DIR/_kubectl"' \
    'helm:helm completion zsh > "$COMPLETIONS_DIR/_helm"'
import_atuin_history

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
cd "$DOTFILES_DIR"

mkdir -p "$HOME/Documents/ekphos"
link_configs zsh nvim yazi zellij git ghostty ekphos zed dunst hypr waybar rofi walker gtk

# ==============================================================================
# 15. Apply GTK Dark Theme Preference
# ==============================================================================
echo ">>> Applying GTK dark theme preference <<<"
if command -v gsettings &>/dev/null; then
    run_gsettings() {
        if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && command -v dbus-run-session &>/dev/null; then
            dbus-run-session -- gsettings "$@"
        else
            gsettings "$@"
        fi
    }

    run_gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
    run_gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || true
else
    echo ">>> gsettings not found, skipping system color-scheme preference <<<"
fi

# ==============================================================================
# 16. Set Default Shell
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
