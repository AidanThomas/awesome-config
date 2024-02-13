local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. "/.config/awesome/widgets/tray-widget"
local ICONS_DIR = WIDGET_DIR .. "/icons/"

local M = {}

M.widgets = {}

M.tray = {}
M.tray.widget = wibox.widget {
	{
		margins = 4,
		layout = wibox.container.margin
			{
				valign = "center",
				layout = wibox.container.place
					{
						id = "icon",
						forced_height = 16,
						forced_width = 16,
						widget = wibox.widget.imagebox
					},
			},
	},
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 4)
	end,
	widget = wibox.container.background,
	set_icon = function(self, new_value)
		self:get_children_by_id("icon")[1].image = new_value
	end,
}

M.popup = awful.popup {
	bg = beautiful.bg_normal,
	ontop = true,
	visible = false,
	shape = gears.shape.rounded_rect,
	border_width = 1,
	border_color = beautiful.bg_focus,
	maximum_width = 400,
	offset = { y = 5 },
	widget = {}
}

M.rebuild_popup = function()
	M.widgets = {
		layout = wibox.layout.fixed.horizontal,
	}

	M.popup:setup(M.widgets)
end

M.setup = function(user_args)
	local args = user_args or {}
	M.icon = ICONS_DIR .. "/tray.png"


	M.tray.widget:buttons(
		gears.table.join(
			awful.button({}, 1, function()
				if M.popup.visible then
					M.tray.widget:set_bg(beautiful.bg_normal)
					M.popup.visible = not M.popup.visible
				else
					M.tray.widget:set_bg(beautiful.bg_focus)
					M.popup:move_next_to(mouse.current_widget_geometry)
				end
			end)
		)
	)

	return M.tray.widget
end

return M
