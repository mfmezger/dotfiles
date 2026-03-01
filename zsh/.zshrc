if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configure zoxide to override cd command directly
export ZOXIDE_CMD_OVERRIDE="cd"

# Echo the matched directory before navigating
export _ZO_ECHO=1

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Base plugins for all systems
plugins=(
    # Git
    git
    git-hubflow
    gh
    # Docker
    docker
    docker-compose
    pre-commit
    # SSH
    ssh
    ssh-agent
    # Kubernetes (kubectl/helm are lazy-loaded below for speed)
    golang
    # terminal
    colorize
    colored-man-pages
    eza
    sudo
    history
    rsync
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
)
# Platform-specific plugins
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific plugins
    plugins+=(brew iterm2 macos)
fi

# OPTIMIZATION: Manually handle completion initialization
# Moved ugly logic to separate file to keep .zshrc clean
source $HOME/dotfiles/zsh/fast_init.zsh

source $ZSH/oh-my-zsh.sh

# HISTORY SETTINGS
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
setopt SHARE_HISTORY      # Share history between sessions

# User configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh
    source /opt/homebrew/share/zsh-autosuggestions-abbreviations-strategy/zsh-autosuggestions-abbreviations-strategy.zsh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # zsh-abbr: check Arch path first, then oh-my-zsh custom path
    if [[ -f /usr/share/zsh/plugins/zsh-abbr/zsh-abbr.zsh ]]; then
        source /usr/share/zsh/plugins/zsh-abbr/zsh-abbr.zsh
    elif [[ -f ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-abbr/zsh-abbr.zsh ]]; then
        source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-abbr/zsh-abbr.zsh
    fi
    source $HOME/.local/share/zsh-autosuggestions-abbreviations-strategy/zsh-autosuggestions-abbreviations-strategy.zsh
fi
ZSH_AUTOSUGGEST_STRATEGY=( abbreviations $ZSH_AUTOSUGGEST_STRATEGY )
export LANG=en_US.UTF-8

export EDITOR="nvim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# BASIC STUFF (session-only for faster shell startup)
abbr --quiet --session e="exit"
abbr --quiet --session v="$EDITOR"
abbr --quiet --session c="clear"
abbr --quiet --session g="git"
abbr --quiet --session d="docker"
abbr --quiet --session dc="docker compose"
abbr --quiet --session k="kubectl"

# PYTHON VIRTUAL ENV
abbr --quiet --session av=". .venv/bin/activate"
abbr --quiet --session us="uv sync"

# GITHUB & GIT
abbr --quiet --session init="pre-commit install && cz init"
abbr --quiet --session ga="git add -A"
abbr --quiet --session gs="git status"
abbr --quiet --session gd="git diff"
abbr --quiet --session gl="git log --oneline -10"


abbr --quiet --session gg="git add -A && git commit -m"
abbr --quiet --session gcm="git commit -m"
abbr --quiet --session gp="git push"
abbr --quiet --session gpl="git pull"
abbr --quiet --session gcb="git checkout -b"
abbr --quiet --session gc="git checkout"
abbr --quiet --session pcr="pre-commit run --all-files"
abbr --quiet --session pcu="pre-commit autoupdate"
abbr --quiet --session pt="uv run coverage run -m pytest -o log_cli=true -vvv tests && uv run coverage report && uv run coverage html"

# FANCY NEW TOOLS
abbr --quiet --session ff="fastfetch"
abbr --quiet --session ls="eza -1 -a --icons --group-directories-first"
abbr --quiet --session l="eza -lah --icons --group-directories-first"
abbr --quiet --session ll="eza -lah --icons --group-directories-first"
abbr --quiet --session lt="eza --tree --level 2"
abbr --quiet --session tree="eza --tree"
abbr --quiet --session lg="eza -lah --git --icons --group-directories-first"
abbr --quiet --session cat="bat"

# AI TOOLS
abbr --quiet --session oc="opencode"

# docker
abbr --quiet --session dcb="docker compose build"
abbr --quiet --session dcu="docker compose up"
abbr --quiet --session dcub="docker compose up --build"
abbr --quiet --session dd="docker compose up --build -d"
abbr --quiet --session dl="docker compose logs -f -t"

# kubernetes
abbr --quiet --session tt="tilt down; tilt up"
abbr --quiet --session kgp='kubectl get pods'

# Platform-specific update aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS update command
    abbr --quiet --session update="brew update && brew upgrade && brew cu -f -a && tldr --update && omz update"
    function uu() {
        echo "⚠️  'uu' is deprecated, please use 'update' instead"
        brew update && brew upgrade && brew cu -f -a && tldr --update && omz update
    }
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Arch Linux update command
    abbr --quiet --session update="sudo pacman -Syyu --noconfirm && yay --noconfirm && tldr --update && omz update"
    function uu() {
        echo "⚠️  'uu' is deprecated, please use 'update' instead"
        sudo pacman -Syyu --noconfirm && yay --noconfirm && tldr --update && omz update
    }
    # Zed editor is called 'zeditor' on Linux
    alias zed="zeditor"
    abbr --quiet --session nvitop="uvx nvitop"

    # CUDA
    export PATH=/opt/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
    # cuSPARSELt
    export LD_LIBRARY_PATH=/opt/cusparselt/lib:$LD_LIBRARY_PATH

    # Clipboard (macOS style)
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
fi

# Pre-cached completions (moved to separate file for cleaner .zshrc)
source $HOME/dotfiles/zsh/completions.zsh


# YAZI
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Git Worktree in tmp directory
# Unalias gwt if it exists (conflicts with oh-my-zsh git plugin)
unalias gwt 2>/dev/null

function gwt() {
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: Not a git repository."
        return 1
    fi

    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: gwt <name>"
        return 1
    fi

    local target="HEAD"
    local worktree_dir="/tmp/worktrees/$name"

    # Ensure parent directory exists
    mkdir -p "/tmp/worktrees"

    echo "Creating worktree '$name' for '$target' at '$worktree_dir'..."
    if git worktree add --detach "$worktree_dir" "$target"; then
        if [[ -f "$repo_root/.env" ]]; then
            cp "$repo_root/.env" "$worktree_dir/.env"
            echo "✓ Copied .env"
        fi
        if [[ -f "$repo_root/gcloud.json" ]]; then
            cp "$repo_root/gcloud.json" "$worktree_dir/gcloud.json"
            echo "✓ Copied gcloud.json"
        fi
        cd "$worktree_dir"
    else
        return 1
    fi
}

# Clean up temporary git worktree
function gwtc() {
    local wt_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$wt_root" ]]; then
        echo "Error: Not in a git repository."
        return 1
    fi

    if [[ -d "$wt_root/.git" ]]; then
        echo "Error: This is the main repository. Use 'git worktree remove' manually if needed."
        return 1
    fi

    local main_repo=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)/..
    echo "Removing worktree at '$wt_root' and returning to main repo..."
    cd "$main_repo" && git worktree remove "$wt_root"
}



# Go
export PATH="$PATH:$HOME/go/bin"

# Antigravity
if [[ -d "$HOME/.antigravity/antigravity/bin" ]]; then
    export PATH="$HOME/dotfiles/scripts:$HOME/.antigravity/antigravity/bin:$PATH"
else
    export PATH="$HOME/dotfiles/scripts:$PATH"
fi

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


