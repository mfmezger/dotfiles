#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Get the directory of this script
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ">>> Starting Arch Linux Installation from $DOTFILES_DIR <<<"

# ==============================================================================
# 1. System Update
# ==============================================================================
echo ">>> Updating system packages <<<"
sudo pacman -Syyu --noconfirm

# ==============================================================================
# 2. Install Core Packages via Pacman
# ==============================================================================
echo ">>> Installing core packages <<<"
sudo pacman -S --needed --noconfirm \
    zsh \
    kitty \
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
    git-delta \
    github-cli \
    ghostty \
    ttf-cascadia-code-nerd \
    ttf-cascadia-mono-nerd \
    xclip \
    zed

# ==============================================================================
# 3. Install AUR Packages via Yay
# ==============================================================================
echo ">>> Installing AUR packages <<<"

# Ensure yay is installed
if ! command -v yay &> /dev/null; then
    echo ">>> Installing yay AUR helper <<<"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
fi

yay -S --needed --noconfirm \
    zsh-theme-powerlevel10k-git \
    visual-studio-code-bin \
    brave-bin \
    zsh-abbr \
    discord

# ==============================================================================
# 4. Install Personal Applications (Optional)
# ==============================================================================
echo ""
read -p ">>> Do you want to install personal packages (Obsidian, Steam, etc.)? (y/N) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Enable multilib repository for Steam (requires 32-bit libraries)
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo ">>> Enabling multilib repository for Steam <<<"
        sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
        sudo pacman -Sy --noconfirm
    else
        echo ">>> multilib repository already enabled <<<"
    fi

    echo ">>> Installing personal AUR packages <<<"
    yay -S --needed --noconfirm \
        obsidian \
        steam
else
    echo ">>> Skipping personal packages <<<"
fi

# ==============================================================================
# 5. Install Oh My Zsh & Plugins
# ==============================================================================
echo ">>> Installing Oh My Zsh <<<"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo ">>> Oh My Zsh already installed <<<"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

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
# 6. Install Python Tools (uv & commitizen)
# ==============================================================================
echo ">>> Installing uv <<<"
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo ">>> uv already installed <<<"
fi

# Ensure uv is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

echo ">>> Installing commitizen via uv <<<"
uv tool install commitizen

# ==============================================================================
# 7. Generate Shell Completions
# ==============================================================================
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

# ==============================================================================
# 8. Configure Docker
# ==============================================================================
echo ">>> Configuring Docker <<<"
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker "$USER"

# ==============================================================================
# 9. Security: ClamAV Antivirus
# ==============================================================================
echo ">>> Setting up ClamAV antivirus <<<"
sudo pacman -S --needed --noconfirm clamav
sudo systemctl enable clamav-freshclam
sudo freshclam || echo ">>> Warning: freshclam update failed, will retry on next boot <<<"

# ==============================================================================
# 10. Security: Firewall (UFW)
# ==============================================================================
echo ">>> Configuring UFW firewall <<<"
sudo pacman -S --needed --noconfirm ufw

sudo systemctl enable ufw.service
sudo systemctl start ufw.service

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

# ==============================================================================
# 11. Security: Application Firewall (OpenSnitch)
# ==============================================================================
echo ">>> Setting up OpenSnitch application firewall <<<"
sudo pacman -S --needed --noconfirm opensnitch
sudo systemctl enable --now opensnitchd

# ==============================================================================
# 12. Link Dotfiles
# ==============================================================================
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
backup_if_exists ".config/i3"
backup_if_exists ".config/ghostty"
backup_if_exists ".config/zed"

# Run stow (use --no-folding for i3 to allow scripts folder to be separate)
stow zsh nvim kitty yazi git screenlayout ghostty zed
stow --no-folding i3

# Copy i3 scripts from system skeleton (not tracked in dotfiles)
if [ -d "/etc/skel/.config/i3/scripts" ]; then
    echo ">>> Copying i3 scripts from system skeleton <<<"
    cp -r /etc/skel/.config/i3/scripts "$HOME/.config/i3/"
fi

# ==============================================================================
# 13. Set Default Shell
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
