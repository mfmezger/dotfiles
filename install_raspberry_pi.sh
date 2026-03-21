#!/bin/bash
set -e

# Get the directory of this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Starting Raspberry Pi setup from $DOTFILES_DIR <<<"

source "$DOTFILES_DIR/scripts/common.sh"

# ==============================================================================
# 1. Validate platform
# ==============================================================================
if [[ ! -r /etc/os-release ]]; then
    echo ">>> Error: /etc/os-release not found. This script expects Raspberry Pi OS or another Debian-based distro. <<<"
    exit 1
fi

. /etc/os-release
if [[ "${ID:-}" != "raspbian" && "${ID_LIKE:-}" != *"debian"* && "${ID:-}" != "debian" ]]; then
    echo ">>> Error: This installer is intended for Raspberry Pi OS / Debian-based systems. Detected: ${ID:-unknown}. <<<"
    exit 1
fi

# ==============================================================================
# 2. System update
# ==============================================================================
echo ">>> Updating apt package lists <<<"
sudo apt update
sudo apt upgrade -y

# ==============================================================================
# 3. Install core packages
# ==============================================================================
echo ">>> Installing core packages <<<"
sudo apt install -y \
    zsh \
    stow \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    htop \
    tree \
    neovim \
    bat \
    fd-find \
    ripgrep \
    fzf \
    zoxide \
    xclip

# bat is installed as batcat on Debian/Raspberry Pi OS
if [[ ! -f /usr/local/bin/bat && -f /usr/bin/batcat ]]; then
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
fi

# fd is installed as fdfind on Debian/Raspberry Pi OS
if [[ ! -f /usr/local/bin/fd && -f /usr/bin/fdfind ]]; then
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

# ==============================================================================
# 4. Install modern CLI tools
# ==============================================================================
echo ">>> Installing modern CLI tools <<<"

if ! command -v eza &>/dev/null; then
    if sudo apt install -y eza 2>/dev/null; then
        echo ">>> eza installed via apt <<<"
    else
        echo ">>> eza not available via apt, installing from third-party apt repository <<<"
        sudo install -d -m 0755 /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi
fi

if ! command -v atuin &>/dev/null; then
    bash <(curl -fsSL https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
fi

if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if ! command -v fastfetch &>/dev/null; then
    if sudo apt install -y fastfetch 2>/dev/null; then
        echo ">>> fastfetch installed via apt <<<"
    else
        echo ">>> fastfetch not available in apt, skipping <<<"
    fi
fi

export PATH="$HOME/.local/bin:$PATH"

echo ">>> Installing commitizen via uv <<<"
uv tool install commitizen

# ==============================================================================
# 5. Install Oh My Zsh & plugins
# ==============================================================================
echo ">>> Installing Oh My Zsh <<<"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    export RUNZSH=no
    export CHSH=no
    export KEEP_ZSHRC=yes
    export ZSH="$HOME/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo ">>> Oh My Zsh already installed <<<"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo ">>> Installing Powerlevel10k theme <<<"
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo ">>> Powerlevel10k already installed <<<"
fi

echo ">>> Installing zsh-autosuggestions <<<"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo ">>> zsh-autosuggestions already installed <<<"
fi

echo ">>> Installing zsh-syntax-highlighting <<<"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo ">>> zsh-syntax-highlighting already installed <<<"
fi

echo ">>> Installing zsh-abbr <<<"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-abbr" ]]; then
    git clone https://github.com/olets/zsh-abbr.git "$ZSH_CUSTOM/plugins/zsh-abbr"
else
    echo ">>> zsh-abbr already installed <<<"
fi

echo ">>> Installing zsh-autosuggestions-abbreviations-strategy <<<"
if [[ ! -d "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy" ]]; then
    git clone https://github.com/olets/zsh-autosuggestions-abbreviations-strategy.git \
        "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy"
else
    echo ">>> zsh-autosuggestions-abbreviations-strategy already installed <<<"
fi

# ==============================================================================
# 6. Generate shell completions
# ==============================================================================
echo ">>> Generating shell completions <<<"
COMPLETIONS_DIR="$HOME/.local/share/zsh/completions"
mkdir -p "$COMPLETIONS_DIR"

if command -v uv &>/dev/null; then
    uv generate-shell-completion zsh >"$COMPLETIONS_DIR/_uv"
    uvx --generate-shell-completion zsh >"$COMPLETIONS_DIR/_uvx"
fi

if command -v atuin &>/dev/null; then
    atuin init zsh >"$COMPLETIONS_DIR/atuin-init.zsh"
fi

# ==============================================================================
# 7. Link dotfiles
# ==============================================================================
echo ">>> Linking dotfiles <<<"
cd "$DOTFILES_DIR"

backup_if_exists ".zshrc"
backup_if_exists ".p10k.zsh"
backup_if_exists ".gitconfig"
backup_if_exists ".config/nvim"
backup_if_exists ".config/yazi"

stow zsh git nvim yazi

# ==============================================================================
# 8. Set default shell
# ==============================================================================
echo ">>> Setting zsh as default shell <<<"
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
fi

echo ">>> Raspberry Pi installation completed successfully! <<<"
echo ""
echo "Please log out and log back in to:"
echo "  - Use zsh as your default shell"
