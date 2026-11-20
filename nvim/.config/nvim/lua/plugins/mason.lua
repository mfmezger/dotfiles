-- Customize Mason tool installation
-- AstroNvim routes all Mason installs through mason-tool-installer, so the
-- `ensure_installed` lists of mason-lspconfig/mason-nvim-dap are ignored.
-- Use Mason package names here (e.g. `lua-language-server`, not `lua_ls`).

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "lua-language-server",
        "stylua",
        "ruff",
        "ty",
        "debugpy",
      })
    end,
  },
}
