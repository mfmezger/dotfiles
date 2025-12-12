if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configure zoxide to override cd command directly
export ZOXIDE_CMD_OVERRIDE="cd"

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
    # Kubernetes
    helm
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

# BASIC STUFF
abbr --quiet e="exit"
abbr --quiet v="$EDITOR"
abbr --quiet c="clear"

# PYTHON VIRTUAL ENV
abbr --quiet av=". .venv/bin/activate"
abbr --quiet us="uv sync"

# GITHUB & GIT
abbr --quiet init="pre-commit install && cz init"
abbr --quiet ga="git add -A"
abbr --quiet gs="git status"
abbr --quiet gg="git add . && git commit -m"
abbr --quiet ggp="git add . && pre-commit run --all-files && cz commit && cz bump"
abbr --quiet gp="git push"
abbr --quiet gpl="git pull"
abbr --quiet gcb="git checkout -b"
abbr --quiet gc="git checkout"
abbr --quiet pcr="pre-commit run --all-files"
abbr --quiet pcu="pre-commit autoupdate"
abbr --quieter --force test="uv run coverage run -m pytest -o log_cli=true -vvv tests && uv run coverage report && uv run coverage html"

# FANCY NEW TOOLS
abbr --quiet ff="fastfetch"
abbr --quiet ls="eza -l -a --icons --group-directories-first"
abbr --quiet l="eza -lah --icons --group-directories-first"
abbr --quiet ll="eza -lah --icons --group-directories-first"
abbr --quieter --force cat="bat"

# docker
abbr --quiet dcb="docker compose build"
abbr --quiet dcu="docker compose up"
abbr --quiet dcub="docker compose up --build"
abbr --quieter --force dd="docker compose up --build -d"
abbr --quiet dl="docker compose logs -f -t"

# kubernetes
abbr --quiet tt="tilt down; tilt up"
abbr --quiet k="kubectl"
abbr --quiet kgp='kubectl get pods'

# Platform-specific update aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS update command
    abbr --quiet uu="brew update && brew upgrade && brew cu -f -a && tldr --update && omz update"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Arch Linux update command
    abbr --quiet uu="sudo pacman -Syyu --noconfirm && yay --noconfirm && tldr --update && omz update"
    # Zed editor is called 'zeditor' on Linux
    alias zed="zeditor"
    # CUDA
    export PATH=/opt/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
    # cuSPARSELt
    export LD_LIBRARY_PATH=/opt/cusparselt/lib:$LD_LIBRARY_PATH
fi

# ZSH Tools
if [[ -f "$HOME/.local/share/zsh/completions/atuin-init.zsh" ]]; then
    source "$HOME/.local/share/zsh/completions/atuin-init.zsh"
else
    eval "$(atuin init zsh)"
fi


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
if [[ -f "$HOME/.local/share/zsh/completions/_uv" ]]; then
    source "$HOME/.local/share/zsh/completions/_uv"
    source "$HOME/.local/share/zsh/completions/_uvx"
else
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi

# Added by Antigravity
if [[ -d "$HOME/.antigravity/antigravity/bin" ]]; then
    export PATH="$HOME/.dotfiles/scripts:$HOME/.antigravity/antigravity/bin:$PATH"
else
    export PATH="$HOME/.dotfiles/scripts:$PATH"
fi
