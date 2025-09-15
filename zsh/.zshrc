if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configure zoxide to override cd command directly
export ZOXIDE_CMD_OVERRIDE="cd"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    brew
    colored-man-pages
    eza
	git
    git-hubflow
    docker
    docker-compose
    # dotenv
    helm
    history
    iterm2
    macos
    pre-commit
    colorize
    ssh
    ssh-agent
    sudo
    gh
	golang
    rsync
    zoxide
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# HISTORY SETTINGS
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
setopt SHARE_HISTORY      # Share history between sessions

# User configuration
export LANG=en_US.UTF-8

export EDITOR="nvim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# BASIC STUFF
alias e="exit"
alias v="$EDITOR"
alias c="clear"

# PYTHON VIRTUAL ENV
alias av=". .venv/bin/activate"

# GITHUB & GIT
alias ghcs="gh copilot suggest"
alias gs="git status"
alias gg="git add . && git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gcb="git checkout -b"
alias gc="git checkout"
alias pcr="pre-commit run --all-files"
alias pcu="pre-commit autoupdate"

# FANCY NEW TOOLS
alias ff="fastfetch"
alias ls="eza -l --icons"
alias l="eza -lah --icons"
alias ll="eza -lah --icons"
alias cat="bat"

# docker
alias dcb="docker compose build"
alias dcu="docker compose up"
alias dd="docker compose up --build -d"
alias dl="docker compose logs -f -t"

# kubernetes
alias tt="tilt down; tilt up"
alias k="kubectl"
alias kgp='kubectl get pods'

# update everything
alias uu="brew update && brew upgrade && brew cu -f -a && tldr --update"
alias au="sudo pacman -Syyu --noconfirm && yay && tldr --update && sudo clamav"

# ZSH Tools
eval "$(atuin init zsh)"


# YAZI
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# UV Python Management
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# . "$HOME/.local/bin/env"
source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme
