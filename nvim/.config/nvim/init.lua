-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

-- macOS: pin the SDK used for native builds (treesitter parsers, mason packages).
-- A leftover beta SDK (e.g. MacOSX27.0.sdk) can be picked by `xcrun` even though the
-- installed Command Line Tools linker can't read it ("ld: tapi error: malformed file").
local default_sdk = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
if vim.fn.has "mac" == 1 and not vim.env.SDKROOT and (vim.uv or vim.loop).fs_stat(default_sdk) then
  vim.env.SDKROOT = default_sdk
end

require "lazy_setup"
