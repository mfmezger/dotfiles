-- AstroNvim pins aerial.nvim to ^2.2, but the fix for the
-- `iter_matches({ all = false })` removal in Neovim 0.12+ only landed in 3.0.0.
-- Override the version pin so we can pull the fix.

---@type LazySpec
return {
  { "stevearc/aerial.nvim", version = false },
}
