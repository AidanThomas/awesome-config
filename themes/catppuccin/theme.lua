local awful = require("awful")
awful.util = require("awful.util")

theme_path = awful.util.getdir("config") .. "/themes/catppuccin/"

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- default variables

theme = {}

dofile(theme_path .. "elements.lua")
dofile(theme_path .. "titlebar.lua")
dofile(theme_path .. "layouts.lua")

theme.wallpaper = theme_path .. "dawn-lake.jpg"

return theme
