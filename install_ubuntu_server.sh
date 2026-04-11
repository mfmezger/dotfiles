#!/bin/bash
set -e # Exit on any error

# Get the directory of this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting beautiful terminal setup from $DOTFILES_DIR..."

source "$DOTFILES_DIR/scripts/common.sh"

# Update package lists
echo "📦 Updating package lists..."
sudo apt update

# Install essential packages
echo "📦 Installing essential packages..."
sudo apt install -y \
    zsh \
    stow \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    htop \
    tree \
    vim \
    neovim \
    python3 \
    python3-pip

# Install modern terminal tools available via apt
echo "🔧 Installing modern terminal tools..."

# Install tools available via apt
sudo apt install -y \
    bat \
    fd-find \
    ripgrep

# Create symlinks for Ubuntu package names
# bat is installed as 'batcat' in Ubuntu
if [ ! -f /usr/local/bin/bat ] && [ -f /usr/bin/batcat ]; then
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
fi

# fd is installed as 'fdfind' in Ubuntu
if [ ! -f /usr/local/bin/fd ] && [ -f /usr/bin/fdfind ]; then
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

# Try to install eza via apt (available in Ubuntu 24.04+)
echo "📦 Installing eza..."
if sudo apt install -y rust-eza 2>/dev/null; then
    echo "✅ eza installed via apt"
    # Create symlink if eza binary has different name
    if [ -f /usr/bin/eza ] && [ ! -f /usr/local/bin/eza ]; then
        sudo ln -sf /usr/bin/eza /usr/local/bin/eza
    fi
else
    echo "📥 eza not available via apt, installing from binary..."
    if ! command -v eza &>/dev/null; then
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi
fi

# Install tools that need manual installation
echo "🔧 Installing additional tools..."

# Install zoxide (smart cd)
if ! command -v zoxide &>/dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    sudo mv ~/.local/bin/zoxide /usr/local/bin/
fi

# Install atuin (better history)
if ! command -v atuin &>/dev/null; then
    bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
    sudo mv ~/.cargo/bin/atuin /usr/local/bin/ 2>/dev/null || true
fi

# Install uv (Python package manager)
echo "🐍 Installing uv..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Ensure uv is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# Install Rust toolchain for ekphos
echo "🦀 Installing Rust toolchain..."
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

if [ -f "$HOME/.cargo/env" ]; then
    # Make cargo available immediately after rustup installation.
    . "$HOME/.cargo/env"
fi

# Install commitizen via uv
echo "📝 Installing commitizen..."
uv tool install commitizen

# Install witr (weather tool)
echo "🌤️ Installing witr..."
if ! command -v witr &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/pranshuparmar/witr/main/install.sh | bash
fi

# Install ekphos (Markdown notes app)
echo "📝 Installing ekphos..."
if ! command -v ekphos &>/dev/null; then
    cargo install ekphos
fi

# Install Oh My Zsh
echo "🎨 Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme
echo "⚡ Installing Powerlevel10k theme..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Install zsh plugins
echo "🔌 Installing zsh plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# zsh-abbr (for abbreviations)
echo "🔌 Installing zsh-abbr..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-abbr" ]; then
    git clone https://github.com/olets/zsh-abbr.git $ZSH_CUSTOM/plugins/zsh-abbr
fi

# zsh-autosuggestions-abbreviations-strategy
echo "🔌 Installing zsh-autosuggestions-abbreviations-strategy..."
if [ ! -d "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy" ]; then
    git clone https://github.com/olets/zsh-autosuggestions-abbreviations-strategy.git \
        "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy"
fi

# Generate Shell Completions
echo "📝 Generating shell completions..."
COMPLETIONS_DIR="$HOME/.local/share/zsh/completions"
mkdir -p "$COMPLETIONS_DIR"

# Generate uv completions
if command -v uv &>/dev/null; then
    uv generate-shell-completion zsh >"$COMPLETIONS_DIR/_uv"
    uvx --generate-shell-completion zsh >"$COMPLETIONS_DIR/_uvx"
fi

# Generate atuin init script
if command -v atuin &>/dev/null; then
    atuin init zsh >"$COMPLETIONS_DIR/atuin-init.zsh"
    echo ">>> Importing shell history into atuin <<<"
    atuin import auto -y || {
        echo ">>> Warning: Failed to import shell history into atuin."
        echo ">>> Please check atuin logs or run 'atuin import auto' manually."
    }
fi

# Set zsh as default shell
echo "🐚 Setting zsh as default shell..."
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh
fi

# Link dotfiles using stow
echo "🔗 Linking dotfiles..."
cd "$DOTFILES_DIR"

# Backup common conflict files
backup_if_exists ".zshrc"
backup_if_exists ".p10k.zsh"
backup_if_exists ".gitconfig"
backup_if_exists ".config/nvim"
backup_if_exists ".config/ekphos"

# Run stow for available configs
if [ -d "zsh" ]; then
    stow zsh
    echo "✅ Zsh configuration linked"
fi

if [ -d "git" ]; then
    stow git
    echo "✅ Git configuration linked"
fi

if [ -d "nvim" ]; then
    stow nvim
    echo "✅ Neovim configuration linked"
fi

if [ -d "ekphos" ]; then
    stow ekphos
    echo "✅ Ekphos configuration linked"
fi

echo ""
echo "🎉 Installation completed successfully!"
echo ""
echo "Please log out and log back in to:"
echo "  - Use zsh as your default shell"
echo ""
