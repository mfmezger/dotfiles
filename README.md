# 🔧 Dotfiles :rocket:

Cross-platform dotfiles for macOS and Linux with modern CLI tools and development environment.

My recommended extensions for ai engineering can be installed via the vs-code extensions pack: [AI Engineering Extensions Pack](https://marketplace.visualstudio.com/items?itemName=mfmezger.python-ai-engineering).

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
- **Terminal**: Ghostty, Kitty (backup)
- **Editor**: Neovim, Zed
- **File Navigation**: eza, yazi, zoxide, fd
- **Text & Viewers**: bat, glow, chroma, jq
- **System Monitoring**: btop, htop, dust, duf, fastfetch
- **Git**: git-delta, gh, onefetch, commitizen
- **History & Docs**: atuin, tealdeer
- **DevOps**: k9s, kubectl, helm
- **Launcher**: Albert (Linux), Raycast (macOS)
- **Utilities**: tokei, witr

## Structure

```bash
~/dotfiles/
├── zsh/                    # Zsh configuration (.zshrc, .p10k.zsh)
├── nvim/                   # Neovim configuration
├── kitty/                  # Kitty terminal config
├── ghostty/                # Ghostty terminal config
├── git/                    # Git configuration (.gitconfig)
├── yazi/                   # Yazi file manager
├── zed/                    # Zed editor config
├── opencode/               # OpenCode AI coding agent config (personal install only)
├── i3/                     # i3 window manager (Linux)
├── albert/                 # Albert launcher config (Linux)
├── screenlayout/           # Screen layout scripts (Linux)
├── scripts/                # Utility scripts
├── Brewfile                # macOS packages (work)
├── Brewfile.personal       # macOS packages (personal) - includes OpenCode & Claude Code
├── install_mac.sh          # macOS installer
├── install_linux.sh        # Arch Linux installer
└── install_ubuntu_server.sh # Ubuntu terminal setup
```

## Shortcuts

Shell abbreviations defined in `.zshrc` (type and press space to expand):

### Basic

| Shortcut | Expands To       |
| -------- | ---------------- |
| `e`      | `exit`           |
| `v`      | `$EDITOR` (nvim) |
| `c`      | `clear`          |
| `g`      | `git`            |
| `d`      | `docker`         |
| `k`      | `kubectl`        |
| `pbcopy` | Copy to clipboard (Linux) |
| `pbpaste`| Paste from clipboard (Linux) |

### Python / UV

| Shortcut | Expands To                      |
| -------- | ------------------------------- |
| `av`     | `. .venv/bin/activate`          |
| `us`     | `uv sync`                       |
| `pt`     | Run pytest with coverage report |

### Git

| Shortcut | Expands To                      |
| -------- | ------------------------------- |
| `ga`     | `git add -A`                    |
| `gs`     | `git status`                    |
| `gd`     | `git diff`                      |
| `gg`     | `git add . && git commit -m`    |
| `gl`     | `git log --oneline -10`          |
| `gp`     | `git push`                      |
| `gpl`    | `git pull`                      |
| `gc`     | `git checkout`                  |
| `gcb`    | `git checkout -b`               |
| `pcr`    | `pre-commit run --all-files`    |
| `pcu`    | `pre-commit autoupdate`         |
| `init`   | `pre-commit install && cz init` |

### Kubernetes

| Shortcut | Expands To                      |
| -------- | ------------------------------- |
| `k`      | `kubectl`                       |
| `kgp`    | `kubectl get pods`              |
| `tt`     | `tilt down; tilt up`            |

### Docker

| Shortcut | Expands To                     |
| -------- | ------------------------------ |
| `dcb`    | `docker compose build`         |
| `dcu`    | `docker compose up`            |
| `dcub`   | `docker compose up --build`    |
| `dd`     | `docker compose up --build -d` |
| `dl`     | `docker compose logs -f -t`    |
| `dc`     | `docker compose`               |

### System Update

| Shortcut | Description                                                 |
| -------- | ----------------------------------------------------------- |
| `uu`     | Update all packages (Homebrew on macOS, pacman/yay on Arch) |

### File Listing (eza)

| Shortcut | Expands To                                  |
| -------- | ------------------------------------------- |
| `ls`     | `eza -1 -a --icons --group-directories-first` |
| `l`      | `eza -lah --icons --group-directories-first` |
| `ll`     | `eza -lah --icons --group-directories-first` |
| `lt`     | `eza --tree --level 2`                     |
| `lg`     | `eza -lah --git --icons --group-directories-first` |
| `cat`    | `bat` (syntax-highlighted cat)             |

---

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
| `zed`          | `~/.config/zed`           |
| `opencode`     | `~/.config/opencode`      | (personal install only)
| `i3`           | `~/.config/i3`            |
| `albert`       | `~/.config/albert`        |
| `dunst`        | `~/.config/dunst`         |
| `screenlayout` | `~/.screenlayout`         |

### Apply Configs

```bash
cd ~/dotfiles

# macOS
stow zsh git nvim ghostty yazi zed
stow opencode  # Only after installing personal packages

# Arch Linux
stow zsh git nvim kitty yazi ghostty zed albert
stow --no-folding i3  # Preserves scripts folder

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
