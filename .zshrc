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

alias tt="tilt down; tilt up"

# FANCY NEW TOOLS
alias ls="eza -lah"
alias l="eza -lah"
alias cat="bat"
alias cd="z"
alias k="kubectl"

# update everything
alias uu="brew update && brew upgrade && brew cu -f -a && tldr --update"

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(pyenv init -)"



# PYENV
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

