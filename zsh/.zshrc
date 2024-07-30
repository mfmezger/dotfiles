if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions docker docker-compose zoxide poetry colorize gh golang)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

export EDITOR="nvim"
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='vim'
 fi

# set poetry to only use local venv
export POETRY_VIRTUALENVS_IN_PROJECT=true

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# GITHUB & GIT
alias ghcs="gh copilot suggest"
alias gs="git status"
alias gg="git add . && git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gcb="git checkout -b"
alias gc="git checkout"

alias v="$EDITOR"

# FANCY NEW TOOLS
alias ff="fastfetch"
alias c="clear"
alias ls="eza -l --icons"
alias l="eza -lah --icons"
alias ll="eza -lah --icons"
alias cat="bat"
alias cd="z"

# kubernetes
alias tt="tilt down; tilt up"
alias k="kubectl"

# update everything
alias uu="brew update && brew upgrade && brew cu -f -a && tldr --update"
alias au="sudo pacman -Syyu && tldr --update"

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# PYENV
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
