# Agent Instructions for Dotfiles Repository

This is a personal dotfiles repository for cross-platform (macOS/Linux) development environment. It uses GNU Stow for managing symlinks.

## Installation Commands

```bash
# macOS
./install_mac.sh

# Arch Linux
./install_linux.sh

# Ubuntu (minimal setup)
./install_ubuntu_server.sh

# Apply specific configs using stow
stow zsh git nvim ghostty yazi zed  # macOS
stow zsh git nvim kitty yazi ghostty zed albert  # Arch Linux
stow -n zsh  # Dry run to preview changes
stow -R zsh  # Restow to refresh symlinks
```

## Shell Testing

Test shell scripts by running them in a safe environment:
```bash
# Check syntax
bash -n install_mac.sh

# Test in dry-run mode where supported
stow -n <package>
```

## Git Conventions

Use commitizen for conventional commits:
```bash
init          # Initialize pre-commit and commitizen
cz commit     # Create a commit with conventional format
cz bump       # Bump version based on commits
pcr           # Run pre-commit hooks on all files
pcu           # Update pre-commit hooks
```

## Code Style Guidelines

### Shell Scripts (.sh, .bash, .zsh)
- Indentation: 4 spaces
- Shebang: `#!/bin/bash` at top of file
- Always use `set -e` for error handling
- Use descriptive variable names in UPPER_CASE
- Comment with `#` prefix
- Use functions for complex logic
- Exit immediately on command failure with `set -e`

### Lua (Neovim Config)
- Indentation: 2 spaces
- Max line width: 120 characters
- Use type annotations: `---@type LazySpec`
- Use `-- stylua: ignore` for format exceptions
- Empty tables return `{}`
- Comment with `--` prefix
- Use `if true then return {} end` to disable inactive files

### TOML/YAML/JSON
- Indentation: 2 spaces

### General Rules
- Encoding: UTF-8
- Line endings: LF (Unix-style)
- Trim trailing whitespace
- Always insert final newline
- Use meaningful filenames (lowercase with underscores)

### File Organization

Place configs in appropriate directories:
- `zsh/` - Shell configuration (.zshrc, .p10k.zsh)
- `nvim/.config/nvim/` - Neovim configuration
- `git/.gitconfig` - Git configuration
- `kitty/.config/kitty/` - Kitty terminal config
- `ghostty/.config/ghostty/` - Ghostty terminal config
- `yazi/.config/yazi/` - Yazi file manager config
- `zed/.config/zed/` - Zed editor config
- `opencode/.config/opencode/` - OpenCode AI coding agent config (personal install only)
- `i3/.config/i3/` - i3 window manager config (Linux)
- `albert/.config/albert/` - Albert launcher config (Linux)
- `scripts/` - Utility scripts

### Platform-Specific Handling

Check `$OSTYPE` for platform detection:
- macOS: `$OSTYPE == "darwin"*`
- Linux: `$OSTYPE == "linux-gnu"*`

For example:
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux specific
fi
```

### Editor Config

This repository uses `.editorconfig` for consistency. Editors should use it automatically.

## Common Patterns

### Abbreviations (zsh-abbr)
Abbreviations are defined in `.zshrc` for quick command expansion:
- `v` → `$EDITOR` (nvim)
- `e` → `exit`
- `g` → `git`
- `pt` → Run pytest with coverage

### Pre-commit Hooks
Always run `pre-commit run --all-files` before committing changes.

## Neovim Configuration

Based on AstroNvim v4 with community plugins. Use `lazy.nvim` for plugin management.
- Main config: `nvim/.config/nvim/init.lua`
- Plugin specs: `nvim/.config/nvim/lua/community.lua`, `plugins/`
- Custom settings: `nvim/.config/nvim/lua/polish.lua`

Lua linting uses selene with neovim standard. Format with stylua.

## Stow Notes

- Stow creates symlinks from package directories to home directory
- Use `--no-folding` for packages with scripts folders (e.g., `i3`)
- Conflicts occur when files exist at target location
- Backup and remove conflicting files before stowing

## Commit Message Format

Follow conventional commits (via commitizen):
- `feat:` - New feature
- `fix:` - Bug fix
- `chore:` - Maintenance tasks
- `docs:` - Documentation changes
- `style:` - Code style changes (no functional change)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests

## Version Bumping

Use `cz bump` to automatically bump version based on commit types:
- `feat:` and `fix:` bump patch/minor version
- `BREAKING CHANGE:` bumps major version
