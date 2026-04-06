# Neovim config

Personal AstroNvim v4 configuration managed in this dotfiles repo.

## Structure

- `init.lua` - bootstraps `lazy.nvim` and loads the config
- `lua/lazy_setup.lua` - AstroNvim + Lazy setup
- `lua/community.lua` - AstroCommunity imports
- `lua/plugins/` - plugin overrides and custom plugins

## Enabled features

### Core platform

- [AstroNvim v4](https://github.com/AstroNvim/AstroNvim)
- [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management
- AstroCommunity imports for shared plugin packs

### Language support

Current language/community packs:

- Lua
- Python
  - base pack
  - Ruff integration

### UI and navigation

- `noice.nvim`
- `mini.animate`
- `flash.nvim`
- `harpoon`
- `trouble.nvim`
- `telescope-zoxide`
- `render-markdown.nvim`
- `nvim-spectre`
- `neotest`
- `oil.nvim` on `-`

## Python setup

Python is configured around:

- `ruff` for linting/import organization
- `ty` as the Python language server
- `pyright` and `basedpyright` disabled

Related files:

- `lua/plugins/astrolsp.lua`
- `lua/plugins/mason.lua`

Installed tools include:

- `lua_ls`
- `ruff`
- `ty`
- `stylua`
- Python DAP support

## Notable customizations

### Editor options

Configured in `lua/plugins/astrocore.lua`:

- relative line numbers enabled
- wrapping enabled
- signcolumn always shown
- diagnostics virtual text enabled
- large buffer protections enabled

### Keymaps

Custom normal-mode mappings include:

- `]b` / `[b` - next/previous buffer
- `<Leader>1` .. `<Leader>9` - jump to buffer by tab position
- `<Leader>bd` - choose a buffer from the tabline and close it
- `-` - open `oil.nvim`

## Plugin notes

Custom plugins and overrides currently live in:

- `lua/plugins/user.lua`

This file includes:

- `presence.nvim`
- `lsp_signature.nvim`
- `oil.nvim`
- `nvim-surround`
- custom `alpha-nvim` header
- `LuaSnip` filetype extension for JavaScript
- custom `nvim-autopairs` rules

## Maintenance

### Update plugins

Inside Neovim:

```vim
:Lazy sync
```

### Check tool installs

Inside Neovim:

```vim
:Mason
```

### Lockfile

Plugin versions are pinned in:

- `lazy-lock.json`

## Repo context

This config lives at:

- `nvim/.config/nvim/`

and is intended to be managed via GNU Stow with the rest of this dotfiles repository.
