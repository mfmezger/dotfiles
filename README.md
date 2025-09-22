# 🔧 Dotfiles :rocket:

Cross-platform dotfiles for macOS and Linux with modern CLI tools and development environment.

## Quick Install

```bash
git clone https://github.com/mfmezger/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### macOS
```bash
./install_mac.sh
```
### Arch Linux
```bash
./install_linux.sh
```

### Ubuntu (Minimal Setup)
```bash
./install_ubuntu_server.sh
```

## Key Tools

- **Shell**: Zsh + Oh My Zsh + Powerlevel10k
- **Terminal**: Ghostty (macOS), Kitty (Linux)
- **Editor**: Neovim
- **CLI Tools**: eza, bat, zoxide, atuin, yazi, git-delta, btop

## Structure

```
~/.dotfiles/
├── zsh/                    # Zsh configuration
├── nvim/                   # Neovim configuration  
├── kitty/                  # Kitty terminal config
├── ghostty/                # Ghostty terminal config
├── git/                    # Git configuration
├── yazi/                   # Yazi file manager
├── i3/                     # i3 window manager (Linux)
├── Brewfile                # macOS packages
├── install_mac.sh          # macOS installer
├── install_linux.sh        # Arch Linux installer
└── install_ubuntu_server.sh # Ubuntu terminal setup
```

## Manual Linking

```bash
# macOS
stow zsh nvim kitty yazi git

# Arch Linux  
stow zsh nvim kitty yazi git i3 screenlayout

# Ubuntu (minimal)
stow zsh git nvim
```
