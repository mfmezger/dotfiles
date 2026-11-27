-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      autoformat = true, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      "ruff",
      "ty",
    },
    -- customize language server configuration options passed to `vim.lsp.config`
    ---@diagnostic disable: missing-fields
    config = {
      ruff = {
        init_options = {
          settings = {
            organizeImports = true,
          },
        },
      },
      ty = {
        cmd = { "ty", "server" },
        filetypes = { "python" },
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, { "ty.toml", "pyproject.toml", "setup.py", "setup.cfg", ".git" })
          if root then
            on_dir(root)
          else
            local buffer_name = vim.api.nvim_buf_get_name(bufnr)
            on_dir(buffer_name ~= "" and vim.fs.dirname(buffer_name) or vim.uv.cwd())
          end
        end,
      },
    },
    -- customize which language servers AstroLSP enables
    handlers = {
      -- setting a handler to false disables that language server
      basedpyright = false,
      pyright = false,
    },
    -- NOTE: codelens refresh is handled natively via `vim.lsp.codelens.enable()` on Neovim 0.12+
    -- (controlled by `features.codelens` above), so no manual refresh autocmd is needed.
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client, bufnr)
            return client:supports_method("textDocument/semanticTokens/full", bufnr) and vim.lsp.semantic_tokens
          end,
        },
      },
    },
  },
}
