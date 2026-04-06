# =============================================================================
# PRE-CACHED COMPLETIONS (for faster shell startup)
# =============================================================================
# These completions are pre-generated during install (install_linux.sh / install_mac.sh)
# to avoid slow `eval` calls on every shell startup.
#
# Regenerate with:
#   mkdir -p ~/.local/share/zsh/completions && cd ~/.local/share/zsh/completions
#   atuin init zsh > atuin-init.zsh
#   gh completion -s zsh > _gh
#   docker completion zsh > _docker
#   kubectl completion zsh > _kubectl
#   helm completion zsh > _helm

COMPLETIONS_DIR="$HOME/.local/share/zsh/completions"
mkdir -p "$COMPLETIONS_DIR"

# Atuin (history search)
if [[ -f "$COMPLETIONS_DIR/atuin-init.zsh" ]]; then
    source "$COMPLETIONS_DIR/atuin-init.zsh"
elif command -v atuin >/dev/null 2>&1; then
    eval "$(command atuin init zsh)"
fi

# GitHub CLI
[[ -f "$COMPLETIONS_DIR/_gh" ]] && source "$COMPLETIONS_DIR/_gh"

# Docker
[[ -f "$COMPLETIONS_DIR/_docker" ]] && source "$COMPLETIONS_DIR/_docker"

# Kubectl (lazy-loaded if no cache)
if [[ -f "$COMPLETIONS_DIR/_kubectl" ]]; then
    source "$COMPLETIONS_DIR/_kubectl"
elif command -v kubectl >/dev/null 2>&1; then
    kubectl() {
        unfunction kubectl
        eval "$(command kubectl completion zsh)"
        command kubectl "$@"
    }
fi

# Helm (lazy-loaded if no cache)
if [[ -f "$COMPLETIONS_DIR/_helm" ]]; then
    source "$COMPLETIONS_DIR/_helm"
elif command -v helm >/dev/null 2>&1; then
    helm() {
        unfunction helm
        eval "$(command helm completion zsh)"
        command helm "$@"
    }
fi

# UV Python Manager
if [[ -f "$COMPLETIONS_DIR/_uv" ]]; then
    source "$COMPLETIONS_DIR/_uv"
    source "$COMPLETIONS_DIR/_uvx"
elif command -v uv &>/dev/null; then
    uv generate-shell-completion zsh >"$COMPLETIONS_DIR/_uv"
    uvx --generate-shell-completion zsh >"$COMPLETIONS_DIR/_uvx"
    source "$COMPLETIONS_DIR/_uv"
    source "$COMPLETIONS_DIR/_uvx"
fi

# WT CLI
if [[ -f "$COMPLETIONS_DIR/wt-init.zsh" ]]; then
    source "$COMPLETIONS_DIR/wt-init.zsh"
else
    if command -v wt >/dev/null 2>&1; then
        eval "$(command wt config shell init zsh)"
    fi
fi
