#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Get the directory of this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Starting Installation from $DOTFILES_DIR <<<"

source "$DOTFILES_DIR/scripts/common.sh"

# 1. Install Homebrew
if ! command -v brew &>/dev/null; then
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
read -p ">>> Do you want a minimal install (zsh essentials + zellij)? (y/N) " -n 1 -r
echo # move to a new line
MINIMAL_INSTALL=$REPLY
if [[ $MINIMAL_INSTALL =~ ^[Yy]$ ]]; then
    echo ">>> Installing minimal brew packages (zsh essentials + zellij) <<<"
    brew bundle --file="$DOTFILES_DIR/Brewfile.minimal"
else
    echo ">>> Installing full brew packages <<<"
    brew bundle --file="$DOTFILES_DIR/Brewfile"

    # 2.1 Install Personal Packages (Optional - only for full install)
    read -p ">>> Do you want to install personal packages (Obsidian, WhatsApp, VLC, etc.)? (y/N) " -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ">>> Installing Personal Brew packages <<<"
        brew bundle --file="$DOTFILES_DIR/Brewfile.personal"
    else
        echo ">>> Skipping personal packages <<<"
    fi
fi

# 3. Install Python tools (uv)
ensure_tool uv "uv" 'curl -LsSf https://astral.sh/uv/install.sh | sh'

# 4. Install Rust toolchain (full install only)
if [[ ! $MINIMAL_INSTALL =~ ^[Yy]$ ]]; then
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
else
    echo ">>> Skipping rustup for minimal install <<<"
fi

# 5. Install Oh My Zsh
echo ">>> Installing Oh My Zsh <<<"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo ">>> Oh My Zsh already installed <<<"
fi

# 6. Install Zsh Plugins & Themes
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

ensure_repo "$ZSH_CUSTOM/themes/powerlevel10k" \
    https://github.com/romkatv/powerlevel10k.git --depth=1
ensure_repo "$ZSH_CUSTOM/plugins/zsh-autosuggestions" \
    https://github.com/zsh-users/zsh-autosuggestions
ensure_repo "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
    https://github.com/zsh-users/zsh-syntax-highlighting.git

# 7. Generate Static Completions (Pre-cached for faster shell startup)
COMPLETION_ENTRIES=(
    'uv:uv generate-shell-completion zsh > "$COMPLETIONS_DIR/_uv"; uvx --generate-shell-completion zsh > "$COMPLETIONS_DIR/_uvx"'
    'atuin:atuin init zsh > "$COMPLETIONS_DIR/atuin-init.zsh"'
    'gh:gh completion -s zsh > "$COMPLETIONS_DIR/_gh"'
)
# Docker/Kubernetes completions only for the full install.
if [[ ! $MINIMAL_INSTALL =~ ^[Yy]$ ]]; then
    COMPLETION_ENTRIES+=(
        'docker:docker completion zsh > "$COMPLETIONS_DIR/_docker"'
        'kubectl:kubectl completion zsh > "$COMPLETIONS_DIR/_kubectl"'
        'helm:helm completion zsh > "$COMPLETIONS_DIR/_helm"'
    )
fi
gen_completions "${COMPLETION_ENTRIES[@]}"
import_atuin_history

# 8. Link Dotfiles
echo ">>> Linking dotfiles <<<"
cd "$DOTFILES_DIR"

# Backup common conflict files
backup_if_exists ".zshrc"
backup_if_exists ".p10k.zsh"

# Run stow based on installation type
if [[ $MINIMAL_INSTALL =~ ^[Yy]$ ]]; then
    # Minimal install: link zsh essentials and zellij
    backup_if_exists ".config/zellij"
    stow zsh zellij
    echo ""
    echo ">>> Minimal installation successfully completed! <<<"
    echo ""
    echo "What was installed:"
    echo "  - Zsh with Oh My Zsh + Powerlevel10k theme"
    echo "  - Zellij terminal multiplexer with dotfile config"
    echo "  - Essential plugins: zsh-autosuggestions, zsh-syntax-highlighting, zsh-abbr"
    echo "  - Core tools: atuin, zoxide, eza, bat, yazi, stow"
    echo "  - Development: go, gh, git-delta, uv, fastfetch"
    echo "  - Rust toolchain via rustup was skipped"
    echo "  - Nerd Font for Powerlevel10k icons"
    echo ""
    echo "What was NOT installed:"
    echo "  - GUI applications (terminals, browsers, editors)"
    echo "  - Docker/Kubernetes tools"
    echo "  - System monitoring tools"
    echo "  - Neovim, Yazi, Git, Ghostty, Zed configs (not stowed)"
    echo ""
else
    # Full install: link all dotfiles
    backup_if_exists ".gitconfig"
    backup_if_exists ".config/nvim"
    backup_if_exists ".config/yazi"
    backup_if_exists ".config/zellij"
    backup_if_exists ".config/ghostty"
    backup_if_exists ".config/ekphos"
    mkdir -p "$HOME/Documents/ekphos"
    backup_if_exists ".config/zed"

    stow zsh nvim yazi zellij git ghostty ekphos zed

    echo ""
    echo ">>> Full installation successfully completed! <<<"
    echo ""
    echo "What was also installed:"
    echo "  - Rust toolchain via rustup"
    echo ""
fi

# 9. macOS Settings (applies to both minimal and full install)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ">>> Configuring iTerm2: Load preferences from dotfiles <<<"
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
fi

# 10. Set Default Shell
echo ">>> Setting zsh as default shell <<<"
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    if grep -qFx "$ZSH_PATH" /etc/shells; then
        chsh -s "$ZSH_PATH"
    else
        echo ">>> Warning: $ZSH_PATH is not listed in /etc/shells, so the default shell was not changed. <<<"
        echo ">>> To set it manually, run: <<<"
        echo "sudo sh -c 'echo \"$ZSH_PATH\" >> /etc/shells'"
        echo "chsh -s \"$ZSH_PATH\""
    fi
else
    echo ">>> zsh is already the default shell <<<"
fi

echo ">>> Don't forget to set your git name and email! <<<"
echo "Create ~/.gitconfig.local:"
echo ""
echo 'cat <<EOF > ~/.gitconfig.local'
echo '[user]'
echo '    name = Your Name'
echo '    email = your.email@example.com'
echo 'EOF'

echo ""
echo ">>> Please log out and log back in for any shell changes to take effect. <<<"
