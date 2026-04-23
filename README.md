# 🔧 Dotfiles :rocket:

Cross-platform dotfiles for macOS and Linux with modern CLI tools and a development-focused shell setup.

> My recommended extensions for AI engineering can be installed via the VS Code extensions pack: [AI Engineering Extensions Pack](https://marketplace.visualstudio.com/items?itemName=mfmezger.python-ai-engineering).

> **AI Agents**: Claude Code and OpenCode configs are managed in the separate [ai_agent_dotfiles](https://github.com/mfmezger/ai_agent_dotfiles) repository.

## Quick Install

```bash
git clone https://github.com/mfmezger/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### macOS

The installer is interactive — it prompts for minimal vs. full install and personal packages:

```bash
./install_mac.sh
```

**Brewfile profiles:**

| Profile | File | When to use |
| --- | --- | --- |
| Full | `Brewfile` | Work machine with DevOps/cloud tools |
| Minimal | `Brewfile.minimal` | Shell essentials only (zsh, git, eza, yazi, zellij) |
| Personal | `Brewfile.personal` | AI coding agents, messaging, media (add on top) |

### Arch Linux / CachyOS

```bash
./install_linux.sh
```

### Ubuntu (Minimal Setup)

```bash
./install_ubuntu_server.sh
```

## macOS Installation

The macOS installer is interactive — it prompts for minimal vs. full install and whether to include personal packages.

```bash
./install_mac.sh
```

### Package Profiles

Three Brewfile profiles are available. The installer decides which to use based on your choices:

| Profile | File | What it installs |
|---|---|---|
| **Minimal** | `Brewfile.minimal` | Shell essentials only |
| **Personal** | `Brewfile.personal` | AI agents + media + messaging |
| **All** | `Brewfile` | Full DevOps workstation |

#### Minimal — Shell Essentials

Recommended as a baseline. Installs the core of the dotfiles setup without any GUI apps or cloud/DevOps tooling:

- **Shell**: zsh, zellij, atuin, zoxide, zsh-abbr, zsh-autosuggestions-abbreviations-strategy
- **Core tools**: gh, git-delta, eza, yazi, stow, bat, fastfetch
- **Completions**: kubectl shell completions
- **Fonts**: Nerd Font (Caskaydia Cove)
- **macOS apps**: Maccy (clipboard manager)

No VS Code, no cloud CLIs, no browser — just a fully functional shell environment.

#### Personal — AI Agents + Media + Messaging

Add this on top of minimal to get AI coding agents and everyday macOS apps:

- **AI agents**: OpenCode (OpenCode CLI), Claude Code
- **AI apps**: Obsidian (notes)
- **Media**: VLC, OBS, Shotcut
- **Messaging**: WhatsApp
- **Utilities**: Cyberduck, AppCleaner, Handry

#### All — Full DevOps Workstation

Everything in minimal + personal, plus:

- **Terminal emulators**: Ghostty, iTerm2, Raycast
- **DevOps**: kubectl, helm, k9s
- **System tools**: btop, zenith, dust, duf, fastfetch
- **Browsers**: Brave, Arc
- **Dev editors**: Neovim, Zed, Visual Studio Code, Bruno (API client)
- **Cloud/storage**: Google Drive
- **Utilities**: Rectangle, Alt Tab, Ice, The Unarchiver, Draw.io
- **Languages**: Go, tokei, onefetch, commitizen, wget, xz, poppler, graphviz, ffmpeg
- **Font alternatives**: Caskaydia Mono Nerd Font, Eurkey

The full profile is designed for a work machine. It installs a significant number of casks and compiles several tools from source — expect several minutes for a first run.

#### Which profile should I use?

- **New macOS machine / quick setup** → minimal
- **Work machine with cloud/DevOps** → all
- **Dotfiles sync only (configs, no packages)** → just run `stow` after cloning — no brew install needed

## Change Git Name and Email

Create a `~/.gitconfig.local` file to set your user details without modifying the tracked config:

```bash
cat <<EOF > ~/.gitconfig.local
[user]
    name = Your Name
    email = your.email@example.com
EOF
```

## What's Included

- **Shell**: Zsh + Oh My Zsh + Powerlevel10k
- **Terminal**: Ghostty
- **Terminal Multiplexer**: Zellij
- **Editors**: Neovim, Zed
- **File Navigation**: eza, yazi, zoxide, fd
- **Text & Viewers**: bat, glow, chroma, jq
- **System Monitoring**: btop, htop, dust, duf, fastfetch
- **Git**: git-delta, gh, onefetch, commitizen
- **History & Docs**: atuin, tealdeer
- **DevOps**: k9s, kubectl, helm
- **Launcher**: Rofi (Linux), Raycast (macOS)

## Repository Structure

```bash
~/dotfiles/
├── zsh/                     # Zsh configuration (.zshrc, .p10k.zsh)
├── nvim/                    # Neovim configuration
├── ghostty/                 # Ghostty terminal config
├── kitty/                   # Kitty terminal config
├── zellij/                  # Zellij configuration
├── ekphos/                  # Ekphos notes app config
├── git/                     # Git configuration (.gitconfig)
├── yazi/                    # Yazi file manager
├── zed/                     # Zed editor config
├── hypr/                    # Hyprland configuration (Linux)
├── waybar/                  # Waybar configuration (Linux)
├── rofi/                    # Rofi launcher config (Linux)
├── gtk/                     # GTK theming/config (Linux)
├── screenlayout/            # Screen layout scripts (Linux)
├── scripts/                 # Utility scripts
├── Brewfile                 # macOS packages
├── Brewfile.personal        # macOS personal packages
├── Brewfile.minimal         # Minimal macOS package set
├── install_mac.sh           # macOS installer
├── install_linux.sh         # Arch Linux installer
└── install_ubuntu_server.sh # Ubuntu terminal setup
```

## Reference Docs

- [docs/shortcuts.md](docs/shortcuts.md) — shell abbreviations, aliases, and Zellij shortcuts
- [docs/stow.md](docs/stow.md) — GNU Stow usage, package mapping, and conflict handling

## Stow Quick Start

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs into your home directory.

```bash
cd ~/dotfiles

# macOS
stow zsh git nvim ghostty zellij ekphos yazi zed

# Arch Linux / CachyOS
stow zsh nvim yazi zellij git ghostty ekphos zed dunst hypr waybar rofi gtk

# Ubuntu (minimal)
stow zsh git nvim zellij ekphos
```

For dry runs, unstow/restow commands, package details, and conflict troubleshooting, see [docs/stow.md](docs/stow.md).

## Related Repositories

After installing the main dotfiles, set up AI agent configs from the separate repository if you use them:

```bash
git clone https://github.com/mfmezger/ai_agent_dotfiles.git ~/ai_agent_dotfiles
cd ~/ai_agent_dotfiles
./install.sh
```
