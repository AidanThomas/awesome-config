local awful = require("awful")
local wibox = require("wibox")
local spawn = require("awful.spawn")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. "/.config/awesome/widgets/notification-center-widget"
local ICONS_DIR = WIDGET_DIR .. "/icons/"

local function show_warning(message)
	naughty.notify {
		preset = naughty.config.presets.critical,
		title = 'Notification Center Widget',
		text = message
	}
end

local popup = awful.popup {
	ontop = true,
	visible = false,
	shape = gears.shape.rounded_rect,
	border_width = 1,
	border_color = beautiful.bg_focus,
	maximum_width = 400,
	offset = { y = 5 },
	widget = {},
}

local notification_center_widget = wibox.widget {
	{
		{
			id = "icon",
			widget = wibox.widget.imagebox
		},
		margins = 4,
		layout = wibox.container.margin
	},
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 4)
	end,
	widget = wibox.container.background,
	set_icon = function(self, new_icon)
		self:get_children_by_id("icon")[1].image = new_icon
	end,
}

local function worker(user_args)
	local args = user_args or {}

	local icon = args.icon or ICONS_DIR .. "stock_bell.svg"

	notification_center_widget:set_icon(icon)

	notification_center_widget:buttons(
		gears.table.join(
			awful.button({}, 1, function()
				if popup.visible then
					notification_center_widget:set_bg('#00000000')
					popup.visible = not popup.visible
				else
					notification_center_widget:set_bg(beautiful.bg_focus)
					popup.visible = not popup.visible
				end
			end)
		)
	)

	return notification_center_widget
end

return setmetatable(notification_center_widget, { __call = function(_, ...) return worker(...) end })
