#!/bin/bash
# ==============================================================================
# Shared setup library for the dotfiles install scripts.
#
# Sourced by install_mac.sh, install_linux.sh and install_ubuntu_server.sh so
# the installers call shared helpers instead of re-implementing the same phases
# inline. Every helper is idempotent: safe to run repeatedly.
# ==============================================================================
set -e

# ------------------------------------------------------------------------------
# backup_if_exists <relative-path>
#
# Move an existing real file/dir at $HOME/<relative-path> out of the way before
# stow creates a symlink. Existing symlinks are left untouched. Timestamped
# backups never overwrite each other.
# ------------------------------------------------------------------------------
backup_if_exists() {
    local target="$HOME/$1"
    local timestamp
    local backup_path
    local counter

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        timestamp="$(date +"%Y%m%d-%H%M%S")"
        backup_path="${target}.backup.${timestamp}"
        counter=1

        while [ -e "$backup_path" ]; do
            backup_path="${target}.backup.${timestamp}.${counter}"
            counter=$((counter + 1))
        done

        echo "Backing up existing $target to $backup_path"
        mv "$target" "$backup_path"
    fi
}

# ------------------------------------------------------------------------------
# ensure_tool <command> <description> <installer-command...>
#
# Install a CLI tool only when its <command> is not already on PATH. The
# <installer-command...> is evaluated by the shell so pipelines and flags work
# verbatim (e.g. "curl ... | sh").
#
#   ensure_tool uv "uv" 'curl -LsSf https://astral.sh/uv/install.sh | sh'
# ------------------------------------------------------------------------------
ensure_tool() {
    local cmd="$1"
    local desc="$2"
    shift 2

    if command -v "$cmd" &>/dev/null; then
        echo ">>> $desc already installed <<<"
        return 0
    fi

    echo ">>> Installing $desc <<<"
    # Installer strings may contain pipelines/flags; evaluate as one command.
    eval "$*"
}

# ------------------------------------------------------------------------------
# ensure_repo <target-dir> <git-url> [git-clone-args...]
#
# git clone <git-url> into <target-dir> only when the directory does not yet
# exist. Extra arguments are forwarded to git clone (e.g. --depth=1).
# ------------------------------------------------------------------------------
ensure_repo() {
    local dir="$1"
    local url="$2"
    shift 2
    local name
    name="$(basename "$dir")"

    if [ -d "$dir" ]; then
        echo ">>> $name already installed <<<"
        return 0
    fi

    echo ">>> Installing $name <<<"
    git clone "$@" "$url" "$dir"
}

# ------------------------------------------------------------------------------
# gen_completions <tool:generator> ...
#
# Ensure the zsh completions directory exists, then for each "tool:generator"
# pair run <generator> when <tool> is on PATH. <generator> is evaluated by the
# shell so it may contain redirects and pipelines. The variable COMPLETIONS_DIR
# is exported so generator strings can reference it.
#
#   gen_completions \
#       'uv:uv generate-shell-completion zsh > "$COMPLETIONS_DIR/_uv"' \
#       'gh:gh completion -s zsh > "$COMPLETIONS_DIR/_gh"'
# ------------------------------------------------------------------------------
gen_completions() {
    echo ">>> Generating shell completions <<<"
    export COMPLETIONS_DIR="$HOME/.local/share/zsh/completions"
    mkdir -p "$COMPLETIONS_DIR"

    local entry tool generator
    for entry in "$@"; do
        tool="${entry%%:*}"
        generator="${entry#*:}"
        if command -v "$tool" &>/dev/null; then
            echo ">>> Generating $tool completions <<<"
            eval "$generator"
        fi
    done
}

# ------------------------------------------------------------------------------
# import_atuin_history
#
# Import existing shell history into atuin when atuin is installed. Non-fatal on
# failure so a broken import never aborts the installer.
# ------------------------------------------------------------------------------
import_atuin_history() {
    command -v atuin &>/dev/null || return 0
    echo ">>> Importing shell history into atuin <<<"
    atuin import auto || {
        echo ">>> Warning: Failed to import shell history into atuin."
        echo ">>> Please check atuin logs or run 'atuin import auto' manually."
    }
}
