-- Disable none-ls (broken on Neovim 0.12+, in maintenance mode upstream).
-- Formatting is handled by conform.nvim (imported via community.lua).

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}
