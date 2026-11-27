# Login-shell environment. Runs before ~/.zshrc for login shells (every new
# terminal tab on macOS). Keep it to PATH-style setup.

# Homebrew: PATH, MANPATH, HOMEBREW_PREFIX (Apple Silicon, Intel, Linuxbrew)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# JetBrains Toolbox CLI launchers (pycharm, …)
if [[ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
    export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# Per-host login additions (not tracked in dotfiles)
if [[ -f ~/.zprofile.local ]]; then
    source ~/.zprofile.local
fi
