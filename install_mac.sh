#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of this script
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ">>> Starting Installation from $DOTFILES_DIR <<<"

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
    echo ">>> Installing Homebrew <<<"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo ">>> Homebrew already installed <<<"
fi

# 2. Install Packages
echo ">>> Installing Brew packages <<<"
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 2.1 Install Personal Packages (Optional)
read -p ">>> Do you want to install personal packages (Obsidian, WhatsApp, VLC, etc.)? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ">>> Installing Personal Brew packages <<<"
    brew bundle --file="$DOTFILES_DIR/Brewfile.personal"
else
    echo ">>> Skipping personal packages <<<"
fi

# 3. Install Python tools (uv)
echo ">>> Installing uv <<<"
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo ">>> uv already installed <<<"
fi

# 4. Install Oh My Zsh
echo ">>> Installing Oh My Zsh <<<"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo ">>> Oh My Zsh already installed <<<"
fi

# 5. Install Zsh Plugins & Themes
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo ">>> Installing Powerlevel10k <<<"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo ">>> Powerlevel10k already installed <<<"
fi

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

# 6. Generate Static Completions (Speed up shell startup)
echo ">>> Generating shell completions <<<"
COMPLETIONS_DIR="$HOME/.local/share/zsh/completions"
mkdir -p "$COMPLETIONS_DIR"

# Generate uv completions
if command -v uv &> /dev/null; then
    uv generate-shell-completion zsh > "$COMPLETIONS_DIR/_uv"
    uvx --generate-shell-completion zsh > "$COMPLETIONS_DIR/_uvx"
fi

# Generate atuin init script
if command -v atuin &> /dev/null; then
    atuin init zsh > "$COMPLETIONS_DIR/atuin-init.zsh"
fi

# 7. Link Dotfiles
echo ">>> Linking dotfiles <<<"
cd "$DOTFILES_DIR"

# Function to backup if file exists and is not a symlink
backup_if_exists() {
    local target="$HOME/$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
}

# Backup common conflict files
backup_if_exists ".zshrc"
backup_if_exists ".p10k.zsh"
backup_if_exists ".gitconfig"
backup_if_exists ".config/nvim"
backup_if_exists ".config/kitty"
backup_if_exists ".config/yazi"
backup_if_exists ".config/ghostty"

# Run stow
stow zsh nvim kitty yazi git ghostty zed

echo ">>> Installation successfully completed! <<<"
