# 🔧 Dotfiles :rocket:

Cross-platform dotfiles for macOS and Linux with modern CLI tools and development environment.

## Quick Install

```bash
git clone https://github.com/mfmezger/dotfiles.git ~/dotfiles
cd ~/dotfiles
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

## Change Git Name and Email

Create a `~/.gitconfig.local` file to set your user details without modifying the tracked config:

```bash
cat <<EOF > ~/.gitconfig.local
[user]
    name = Your Name
    email = your.email@example.com
EOF
```

## Key Tools

- **Shell**: Zsh + Oh My Zsh + Powerlevel10k
- **Terminal**: Ghostty (macOS), Kitty (Linux)
- **Editor**: Neovim
- **CLI Tools**: eza, bat, zoxide, atuin, yazi, git-delta, btop

## Structure

```bash
~/dotfiles/
├── zsh/                    # Zsh configuration (.zshrc, .p10k.zsh)
├── nvim/                   # Neovim configuration  
├── kitty/                  # Kitty terminal config
├── ghostty/                # Ghostty terminal config
├── git/                    # Git configuration (.gitconfig)
├── yazi/                   # Yazi file manager
├── i3/                     # i3 window manager (Linux)
├── screenlayout/           # Screen layout scripts (Linux)
├── scripts/                # Utility scripts
├── Brewfile                # macOS packages (work)
├── Brewfile.personal       # macOS packages (personal)
├── install_mac.sh          # macOS installer
├── install_linux.sh        # Arch Linux installer
└── install_ubuntu_server.sh # Ubuntu terminal setup
```

## Stow Usage

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs to your home directory.

### Stow Packages

| Package        | Creates Symlinks          |
| -------------- | ------------------------- |
| `zsh`          | `~/.zshrc`, `~/.p10k.zsh` |
| `git`          | `~/.gitconfig`            |
| `nvim`         | `~/.config/nvim`          |
| `ghostty`      | `~/.config/ghostty`       |
| `kitty`        | `~/.config/kitty`         |
| `yazi`         | `~/.config/yazi`          |
| `i3`           | `~/.config/i3`            |
| `screenlayout` | `~/.screenlayout`         |

### Apply Configs

```bash
cd ~/dotfiles

# macOS
stow zsh git nvim ghostty yazi

# Arch Linux  
stow zsh git nvim kitty yazi i3 screenlayout

# Ubuntu (minimal)
stow zsh git nvim
```

### Dry Run (Preview Changes)

```bash
stow -n zsh  # Shows what would happen without making changes
```

### Remove Symlinks

```bash
stow -D zsh  # Unstow a package
```

### Restow (Refresh Symlinks)

```bash
stow -R zsh  # Useful after adding new files to a package
```

### Troubleshooting Conflicts

If stow reports conflicts, you likely have existing files that aren't symlinks:

```bash
# Backup and remove conflicting files
mv ~/.zshrc ~/.zshrc.backup
mv ~/.gitconfig ~/.gitconfig.backup

# Then stow again
stow zsh git
```
