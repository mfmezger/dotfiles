autoload -Uz add-zsh-hook

function _zellij_repo_context() {
    local repo_root
    repo_root=$(command git rev-parse --show-toplevel 2>/dev/null) || return 1

    local repo_name="${repo_root:t}"
    local git_ref
    git_ref=$(command git branch --show-current 2>/dev/null)

    if [[ -z "$git_ref" ]]; then
        git_ref=$(command git rev-parse --short HEAD 2>/dev/null) || return 1
        git_ref="detached@$git_ref"
    fi

    print -r -- "$repo_name [$git_ref]"
}

function _update_zellij_pane_title() {
    [[ -n "$ZELLIJ" ]] || return

    local pane_title="${PWD:t}"
    local repo_context
    repo_context=$(_zellij_repo_context)

    if [[ -n "$repo_context" ]]; then
        pane_title="$repo_context"
    fi

    # Zellij derives automatic pane names from the terminal title.
    printf '\033]0;%s\007' "$pane_title"
}

add-zsh-hook chpwd _update_zellij_pane_title
add-zsh-hook precmd _update_zellij_pane_title

# Set the initial pane title when the shell starts inside Zellij.
_update_zellij_pane_title
