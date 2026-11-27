-- Disable none-ls (in maintenance mode upstream).
-- Formatting is handled by conform.nvim, imported via community.lua;
-- formatters are set by the language packs (stylua for Lua, ruff for Python).

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false },
}
