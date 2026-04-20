# Shortcuts and Shell Workflow

Most command shortcuts in this repo are defined in [`zsh/.zshrc`](../zsh/.zshrc) using `zsh-abbr`.

## How abbreviations work

Type the abbreviation and press space to expand it.

Example:

- typing `gs` + space becomes `git status`
- typing `av` + space becomes `. .venv/bin/activate`

For the source of truth, see:

- [`zsh/.zshrc`](../zsh/.zshrc)
- [`zellij/.config/zellij/config.kdl`](../zellij/.config/zellij/config.kdl)

## Basic Shell

| Shortcut | Expands To |
| -------- | ---------- |
| `e` | `exit` |
| `v` | `$EDITOR` |
| `c` | `clear` |
| `g` | `git` |
| `d` | `docker` |
| `dc` | `docker compose` |
| `k` | `kubectl` |
| `md` | `ekphos` |
| `ff` | `fastfetch` |
| `oc` | `opencode` |

## Python / UV

| Shortcut | Expands To |
| -------- | ---------- |
| `av` | `. .venv/bin/activate` |
| `us` | `uv sync` |
| `pt` | `uv run coverage run -m pytest -o log_cli=true -vvv tests && uv run coverage report && uv run coverage html` |

## Git

| Shortcut | Expands To |
| -------- | ---------- |
| `init` | `pre-commit install && cz init` |
| `ga` | `git add -A` |
| `gs` | `git status` |
| `gd` | `git diff` |
| `gl` | `git log --oneline -10` |
| `gg` | `git add -A && git commit -m` |
| `gcm` | `git commit -m` |
| `gp` | `git push` |
| `gpl` | `git pull` |
| `gc` | `git checkout` |
| `gcb` | `git checkout -b` |
| `pcr` | `pre-commit run --all-files` |
| `pcu` | `pre-commit autoupdate` |

### Git Worktrees

Worktrees are created under `/tmp/worktrees/<name>`. If present, `.env` and `gcloud.json` are copied from the main repo into the new worktree.

| Command | Behavior |
| ------- | -------- |
| `gwt <name> [target]` | Create a detached worktree at `/tmp/worktrees/<name>` from `target`, or from `main` by default (`GWT_BASE` can override), then `cd` into it |
| `gwtc` | From inside a worktree, remove the current worktree and `cd` back to the main repo |

> Note: `gwt` is a shell function rather than an abbreviation because it needs to change the current shell directory after creating the worktree.

## File Listing and Viewing

| Shortcut | Expands To |
| -------- | ---------- |
| `ls` | `eza -1 -a --icons --group-directories-first` |
| `l` | `eza -lah --icons --group-directories-first` |
| `ll` | `eza -lah --icons --group-directories-first` |
| `lt` | `eza --tree --level 2` |
| `tree` | `eza --tree` |
| `lg` | `eza -lah --git --icons --group-directories-first` |
| `cat` | `bat` |

## Docker

| Shortcut | Expands To |
| -------- | ---------- |
| `dcb` | `docker compose build` |
| `dcu` | `docker compose up` |
| `dcub` | `docker compose up --build` |
| `dd` | `docker compose up --build -d` |
| `dl` | `docker compose logs -f -t` |

## Kubernetes

| Shortcut | Expands To |
| -------- | ---------- |
| `kgp` | `kubectl get pods` |
| `tt` | `tilt down; tilt up` |

## System Update

Preferred command:

| Shortcut | Expands To |
| -------- | ---------- |
| `update` | macOS: `brew update && brew upgrade && brew cu -f -a && tldr --update && omz update` |
| `update` | Linux: `paru -Syyu --noconfirm && tldr --update && omz update` |

Legacy compatibility:

| Command | Notes |
| ------- | ----- |
| `uu` | Still works, but prints a deprecation warning and then runs `update` |

## Platform-Specific Commands

### Linux only

| Command | Behavior |
| ------- | -------- |
| `pbcopy` | Alias to `xclip -selection clipboard` |
| `pbpaste` | Alias to `xclip -selection clipboard -o` |
| `nvitop` | Expands to `uvx nvitop` |
| `audio` | Expands to `pavucontrol` |
| `zed` | Alias to `zeditor` |

## Zellij Quick Reference

Most-used Zellij shortcuts from [`config.kdl`](../zellij/.config/zellij/config.kdl):

| Shortcut | Action |
| -------- | ------ |
| `Alt+n` | Open a new pane |
| `Alt+s` | Open a stacked pane |
| `Alt+h` | Move focus left |
| `Alt+j` | Move focus down |
| `Alt+k` | Move focus up |
| `Alt+l` | Move focus right |
| `Alt+o` | Previous tab |
| `Alt+p` | Next tab |
| `Alt+t` | New tab |
| `Alt+i` | Move tab left |
| `Alt+f` | Toggle floating panes |
| `Ctrl+p` | Enter pane mode |
| `Ctrl+t` | Enter tab mode |
| `Ctrl+n` | Enter resize mode |
| `Ctrl+h` | Enter move mode |
| `Ctrl+s` | Enter scroll mode |
| `Ctrl+o` | Enter session mode |
| `Ctrl+g` | Lock Zellij keybindings; press again to return |

If you want to explore more bindings, the config file is the canonical reference.
