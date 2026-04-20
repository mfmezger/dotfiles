# 🔧 Dotfiles :rocket:

Cross-platform dotfiles for macOS and Linux with modern CLI tools and development environment.

> My recommended extensions for ai engineering can be installed via the vs-code extensions pack: [AI Engineering Extensions Pack](https://marketplace.visualstudio.com/items?itemName=mfmezger.python-ai-engineering).

> **AI Agents**: Claude Code and OpenCode configs are managed in the separate [ai_agent_dotfiles](https://github.com/mfmezger/ai_agent_dotfiles) repository.

## Table of Contents

- [Quick Install](#quick-install)
  - [macOS](#macos)
  - [Arch Linux / CachyOS](#arch-linux--cachyos)
  - [Ubuntu (Minimal Setup)](#ubuntu-minimal-setup)
- [Change Git Name and Email](#change-git-name-and-email)
- [Key Tools](#key-tools)
- [Structure](#structure)
- [Shortcuts](#shortcuts)
  - [Zellij](#zellij)
  - [Basic](#basic)
  - [Python / UV](#python--uv)
  - [Git](#git)
  - [Kubernetes](#kubernetes)
  - [Docker](#docker)
  - [System Update](#system-update)
  - [File Listing (eza)](#file-listing-eza)
- [Stow Usage](#stow-usage)
  - [Stow Packages](#stow-packages)
  - [Apply Configs](#apply-configs)
  - [Dry Run (Preview Changes)](#dry-run-preview-changes)
  - [Remove Symlinks](#remove-symlinks)
  - [Restow (Refresh Symlinks)](#restow-refresh-symlinks)
  - [Troubleshooting Conflicts](#troubleshooting-conflicts)

## Quick Install

```bash
git clone https://github.com/mfmezger/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### macOS

macOS installation uses Homebrew and has three profiles depending on your use case:

| Profile        | File               | What it includes                                      |
| -------------- | ------------------ | ----------------------------------------------------- |
| **All**        | `Brewfile`         | Full work setup (DevOps, cloud tools, productivity)  |
| **Minimal**    | `Brewfile.minimal` | Essentials only (zsh, git, eza, yazi, shell tools)   |
| **Personal**   | `Brewfile.personal`| Personal apps (AI coding tools, messaging, media)     |

```bash
# Run the base installer (sets up Homebrew, zsh, and stow)
./install_mac.sh

# Then apply dotfiles with stow
stow zsh git nvim ghostty zellij ekphos yazi zed

# Install all work packages (DevOps, cloud, productivity)
brew bundle --file=Brewfile

# OR install only the minimal shell essentials
brew bundle --file=Brewfile.minimal

# Personal packages (AI coding agents, messaging, media)
brew bundle --file=Brewfile.personal
```

You can combine profiles — for example, start with `Brewfile.minimal` and add `Brewfile.personal` on top for personal machines.

### Arch Linux / CachyOS

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
- **Terminal**: Ghostty
- **Terminal Multiplexer**: Zellij
- **Editor**: Neovim, Zed
- **File Navigation**: eza, yazi, zoxide, fd
- **Text & Viewers**: bat, glow, chroma, jq
- **System Monitoring**: btop, htop, dust, duf, fastfetch
- **Git**: git-delta, gh, onefetch, commitizen
- **History & Docs**: atuin, tealdeer
- **DevOps**: k9s, kubectl, helm
- **Launcher**: Rofi (Linux), Raycast (macOS)
- **Utilities**: tokei, witr

> **AI Coding Agents**: See [ai_agent_dotfiles](https://github.com/mfmezger/ai_agent_dotfiles) for Claude Code and OpenCode configurations.

## Structure

```bash
~/dotfiles/
├── zsh/                    # Zsh configuration (.zshrc, .p10k.zsh)
├── nvim/                   # Neovim configuration
├── ghostty/                # Ghostty terminal config
├── zellij/                 # Zellij terminal multiplexer config
├── ekphos/                 # Ekphos notes app config
├── git/                    # Git configuration (.gitconfig)
├── yazi/                   # Yazi file manager
├── zed/                    # Zed editor config
├── hypr/                   # Hyprland configuration (CachyOS/Linux)
├── waybar/                 # Waybar top bar (Hyprland/Linux)
├── screenlayout/           # Screen layout scripts (Linux)
├── scripts/                # Utility scripts
├── Brewfile                # macOS packages (work)
├── Brewfile.personal       # macOS packages (personal)
├── install_mac.sh          # macOS installer
├── install_linux.sh        # Arch Linux installer
└── install_ubuntu_server.sh # Ubuntu terminal setup
```

> **Note**: AI coding agent configurations (Claude Code, OpenCode) are managed in a separate repository: [ai_agent_dotfiles](https://github.com/mfmezger/ai_agent_dotfiles). This keeps AI tool configs separate from general development dotfiles.

## Shortcuts

Shell abbreviations defined in `.zshrc` (type and press space to expand):

### Zellij

Most-used Zellij shortcuts:

| Shortcut | Action |
| -------- | ------ |
| `Alt+n`  | Open a new pane |
| `Alt+s`  | Open a stacked split |
| `Alt+h`  | Move focus left |
| `Alt+j`  | Move focus down |
| `Alt+k`  | Move focus up |
| `Alt+l`  | Move focus right |

### Basic

| Shortcut | Expands To       |
| -------- | ---------------- |
| `e`      | `exit`           |
| `v`      | `$EDITOR` (nvim) |
| `c`      | `clear`          |
| `g`      | `git`            |
| `d`      | `docker`         |
| `k`      | `kubectl`        |
| `md`     | `ekphos`         |
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
| `zellij`       | `~/.config/zellij`        |
| `ekphos`       | `~/.config/ekphos`        |
| `yazi`         | `~/.config/yazi`          |
| `zed`          | `~/.config/zed`           |
| `hypr`         | `~/.config/hypr`          |
| `dunst`        | `~/.config/dunst`         |
| `waybar`       | `~/.config/waybar`        |
| `screenlayout` | `~/.screenlayout`         |



### Apply Configs

```bash
cd ~/dotfiles

# macOS
stow zsh git nvim ghostty zellij ekphos yazi zed

# Arch Linux / CachyOS
stow zsh nvim yazi zellij git ghostty ekphos zed dunst hypr waybar rofi gtk

# Ubuntu (minimal)
stow zsh git nvim zellij ekphos
```

> **After installing main dotfiles**, set up AI agent configs from the separate repository.
> ```bash
> git clone https://github.com/mfmezger/ai_agent_dotfiles.git ~/ai_agent_dotfiles
> cd ~/ai_agent_dotfiles
> ./install.sh
> ```

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
