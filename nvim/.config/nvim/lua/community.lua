-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- Recipes & Core
  { import = "astrocommunity.recipes.vscode" },

  -- Language Packs
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python" },

  -- Fuzzy Finding
  { import = "astrocommunity.fuzzy-finder.telescope-zoxide" },

  -- UI Enhancements
  { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.scrolling.mini-animate" },

  -- Navigation & Motion
  { import = "astrocommunity.motion.harpoon" },      -- ThePrimeagen/harpoon branch=harpoon2
  { import = "astrocommunity.motion.flash-nvim" },

  -- Search & Replace
  { import = "astrocommunity.search.nvim-spectre" },

  -- Diagnostics
  { import = "astrocommunity.diagnostics.trouble-nvim" },

  -- Testing
  { import = "astrocommunity.test.neotest" },

  -- Markdown & Documentation
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },

  -- import/override with your plugins folder
}
