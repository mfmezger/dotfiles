-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics_mode = 3,
      highlighturl = true,
      notifications = true,
    },
    -- Diagnostics configuration
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = true,
      },
      g = {},
    },
    -- Keymappings
    mappings = {
      n = {
        -- Navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- Jump to buffer by number (1-9)
        ["<Leader>1"] = { function() require("astrocore.buffer").nav_to(1) end, desc = "Buffer 1" },
        ["<Leader>2"] = { function() require("astrocore.buffer").nav_to(2) end, desc = "Buffer 2" },
        ["<Leader>3"] = { function() require("astrocore.buffer").nav_to(3) end, desc = "Buffer 3" },
        ["<Leader>4"] = { function() require("astrocore.buffer").nav_to(4) end, desc = "Buffer 4" },
        ["<Leader>5"] = { function() require("astrocore.buffer").nav_to(5) end, desc = "Buffer 5" },
        ["<Leader>6"] = { function() require("astrocore.buffer").nav_to(6) end, desc = "Buffer 6" },
        ["<Leader>7"] = { function() require("astrocore.buffer").nav_to(7) end, desc = "Buffer 7" },
        ["<Leader>8"] = { function() require("astrocore.buffer").nav_to(8) end, desc = "Buffer 8" },
        ["<Leader>9"] = { function() require("astrocore.buffer").nav_to(9) end, desc = "Buffer 9" },

        -- Close buffer from tabline picker
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },
      },
    },
  },
}
