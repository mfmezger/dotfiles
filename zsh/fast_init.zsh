# OPTIMIZATION: Manually handle completion initialization
# This file wraps compinit to intercept the call from Oh My Zsh
# It implements caching (once per 24h) and skips security checks for speed.

function compinit() {
  # XDG-compliant cache path for cleaner home directory
  local _comp_dumpfile="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
  mkdir -p "${_comp_dumpfile:h}"
  local _comp_dump_age=999999

  # Calculate file age with error handling\n
  if [[ -f "$_comp_dumpfile" ]]; then
      if [[ "$OSTYPE" == "darwin"* ]]; then
          _comp_dump_age=$(($(date +%s) - $(stat -f %m "$_comp_dumpfile" 2>/dev/null || echo 0)))
      else
          _comp_dump_age=$(($(date +%s) - $(stat -c %Y "$_comp_dumpfile" 2>/dev/null || echo 0)))
      fi
  fi

  # Release the wrapper function so we can call the real compinit
  unfunction compinit
  autoload -Uz compinit

  # Re-run full check only if older than 24 hours
  if [[ $_comp_dump_age -lt 86400 ]]; then
    compinit -C -d "$_comp_dumpfile"
  else
    compinit -d "$_comp_dumpfile"
  fi

  # Compile zcompdump for faster loading (backgrounded for faster startup)
  if [[ ! -f "$_comp_dumpfile.zwc" || "$_comp_dumpfile" -nt "$_comp_dumpfile.zwc" ]]; then
      zcompile "$_comp_dumpfile" &!
  fi
}
