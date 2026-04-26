local color = require "astrotheme.lib.color"

---@class AstroThemePalette
local c = {
  none = "NONE",
  syntax = {},
  ui = {},
  term = {},
  icon = {},
}

--------------------------------
--- Syntax
--------------------------------
c.syntax.red = "#FF3333"
c.syntax.orange = "#FD971F"
c.syntax.yellow = "#FFC44C"
c.syntax.green = "#9ED54E"
c.syntax.cyan = "#00B7C9"
c.syntax.blue = "#6796E6"
c.syntax.purple = "#D27CED"
c.syntax.text = "#B8BCC2"
c.syntax.comment = "#8893A1"
c.syntax.mute = "#8893A1"

--------------------------------
--- UI
--------------------------------
c.ui.red = "#FF3333"
c.ui.orange = "#FD971F"
c.ui.yellow = "#FFC44C"
c.ui.green = "#9ED54E"
c.ui.cyan = "#00B7C9"
c.ui.blue = "#6796E6"
c.ui.purple = "#D27CED"

c.ui.accent = c.ui.cyan

c.ui.tabline = "#0D0E11"
c.ui.winbar = "#8893A1"
c.ui.tool = "#15171C"
c.ui.base = "#0D0E11"
c.ui.inactive_base = "#15171C"
c.ui.statusline = "#15171C"
c.ui.split = "#2C313A"
c.ui.float = "#15171C"
c.ui.title = c.ui.accent
c.ui.border = "#2C313A"
c.ui.current_line = "#1E2330"
c.ui.scrollbar = c.ui.accent
c.ui.selection = "#1E2330"
c.ui.menu_selection = c.ui.selection
c.ui.highlight = "#1A202B"
c.ui.none_text = "#2C313A"
c.ui.text = "#8893A1"
c.ui.text_active = "#B8BCC2"
c.ui.text_inactive = "#2C313A"
c.ui.text_match = "#FDC114"

c.ui.prompt = "#15171C"

--------------------------------
--- Terminal
--------------------------------
c.term.black = c.ui.tabline
c.term.bright_black = color.new(c.ui.tabline):lighten(35):tohex()

c.term.red = c.syntax.red
c.term.bright_red = color.new(c.syntax.red):lighten(35):tohex()

c.term.green = c.syntax.green
c.term.bright_green = color.new(c.syntax.green):lighten(35):tohex()

c.term.yellow = c.syntax.yellow
c.term.bright_yellow = color.new(c.syntax.yellow):lighten(35):tohex()

c.term.blue = c.syntax.blue
c.term.bright_blue = color.new(c.syntax.blue):lighten(35):tohex()

c.term.purple = c.syntax.purple
c.term.bright_purple = color.new(c.syntax.purple):lighten(35):tohex()

c.term.cyan = c.syntax.cyan
c.term.bright_cyan = color.new(c.syntax.cyan):lighten(35):tohex()

c.term.white = c.ui.text_active
c.term.bright_white = color.new(c.syntax.text):lighten(35):tohex()

c.term.background = c.ui.base
c.term.foreground = c.ui.text_active

--------------------------------
--- Icons
--------------------------------
c.icon.c = c.ui.blue
c.icon.css = c.ui.blue
c.icon.deb = c.ui.purple
c.icon.docker = c.ui.cyan
c.icon.html = c.ui.red
c.icon.jpeg = c.ui.purple
c.icon.jpg = c.ui.purple
c.icon.js = c.ui.yellow
c.icon.jsx = c.ui.cyan
c.icon.kt = c.ui.green
c.icon.lock = c.ui.yellow
c.icon.lua = c.ui.blue
c.icon.mp3 = c.ui.purple
c.icon.mp4 = c.ui.purple
c.icon.out = c.ui.text_active
c.icon.png = c.ui.purple
c.icon.py = c.ui.blue
c.icon.rb = c.ui.red
c.icon.robots = c.ui.text_active
c.icon.rpm = c.ui.red
c.icon.rs = c.ui.orange
c.icon.toml = c.ui.green
c.icon.ts = c.ui.blue
c.icon.ttf = c.ui.text_active
c.icon.vue = c.ui.green
c.icon.woff = c.ui.text_active
c.icon.woff2 = c.ui.text_active
c.icon.zip = c.ui.yellow
c.icon.md = c.ui.blue
c.icon.pkg = c.ui.purple

return c
