if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
    dotenv
    helm
    history
    iterm2
    macos
    pre-commit
    poetry
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

# set poetry to only use local venv
export POETRY_VIRTUALENVS_IN_PROJECT=true

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# BASIC STUFF
alias e="exit"
alias v="$EDITOR"
alias c="clear"

# GITHUB & GIT
alias ghcs="gh copilot suggest"
alias gs="git status"
alias gg="git add . && git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gcb="git checkout -b"
alias gc="git checkout"


# FANCY NEW TOOLS
alias ff="fastfetch"
alias ls="eza -l --icons"
alias l="eza -lah --icons"
alias ll="eza -lah --icons"
alias cat="bat"
alias cd="z"

# docker
alias dcb="docker compose build"
alias dcu="docker compose up"
alias dd="docker compose up --build -d"

# kubernetes
alias tt="tilt down; tilt up"
alias k="kubectl"
alias kgp='kubectl get pods'

# update everything
alias uu="brew update && brew upgrade && brew cu -f -a && tldr --update"
alias au="sudo pacman -Syyu -noconfirm&& tldr --update"

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# PYENV
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# RYE
source "$HOME/.rye/env"

# YAZI
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
