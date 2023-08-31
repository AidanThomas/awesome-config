-- Standard awesome library
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local M = {}  -- menu
local _M = {} -- module

-- reading
-- https://awesomewm.org/apidoc/popups%20and%20bars/awful.menu.html

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- This is used later as the default terminal and editor to run.
-- local terminal = "xfce4-terminal"
local terminal = RC.vars.terminal

-- Variable definitions
-- This is used later as the default terminal and editor to run.
local editor = os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

M.awesome = {
	{ "󰌌  Hotkeys", function()
		hotkeys_popup.show_help(nil, awful.screen.focused())
	end },
	{ "  Manual", terminal .. " -e man awesome" },
	{ "󰖷  Edit Config", editor_cmd .. " " .. awesome.conffile },
	{ "  Restart", awesome.restart },
}

M.settings = {
	{ "  Appearance", "lxappearance" },
	{ "󰕾  Sound", "pavucontrol" },
}

M.power = {
	{ "󰍃  Logout", function() awesome.quit() end },
	{ "  Reboot", "reboot" },
	{ "⏻  Shutdown", "shutdown -h now" },
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function _M.get()
	-- Main Menu
	local menu_items = {
		{ "󱃵  Awesome", M.awesome },
		{ "  Terminal", terminal },
		{ "󰈹  Browser", "firefox" },
		{ "󰙯  Discord", "discord" },
		{ "  Files", "nautilus" },
		{ "󰒓  Settings", M.settings },
		{ "⏻  Power", M.power }
	}

	return menu_items
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

return setmetatable({}, { __call = function(_, ...) return _M.get(...) end })
