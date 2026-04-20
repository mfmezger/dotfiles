autoload -Uz add-zsh-hook

function _zellij_repo_context() {
    local git_output
    git_output=$(command git rev-parse --show-toplevel --abbrev-ref HEAD 2>/dev/null) || return 1

    local -a git_info
    git_info=("${(@f)git_output}")
    [[ ${#git_info[@]} -ge 2 ]] || return 1

    local repo_name="${git_info[1]:t}"
    local git_ref="${git_info[2]}"

    if [[ "$git_ref" == "HEAD" ]]; then
        git_ref=$(command git rev-parse --short HEAD 2>/dev/null) || return 1
        git_ref="detached@$git_ref"
    fi

    print -r -- "$repo_name [$git_ref]"
}

function _update_zellij_pane_title() {
    [[ -n "$ZELLIJ" ]] || return

    local pane_title="${PWD:t}"
    [[ -n "$pane_title" ]] || pane_title="/"
    local repo_context
    repo_context=$(_zellij_repo_context)

    if [[ -n "$repo_context" ]]; then
        pane_title="$repo_context"
    fi

    # Zellij derives automatic pane names from the terminal title.
    printf '\033]0;%s\007' "$pane_title"
}

add-zsh-hook precmd _update_zellij_pane_title

# Set the initial pane title when the shell starts inside Zellij.
_update_zellij_pane_title
