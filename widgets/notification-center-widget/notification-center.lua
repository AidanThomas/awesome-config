local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. "/.config/awesome/widgets/notification-center-widget"
local ICONS_DIR = WIDGET_DIR .. "/icons/"

local rows = { layout = wibox.layout.fixed.vertical }
local notification_center_widget = {}
local update_widget
notification_center_widget.widget = wibox.widget {
	{
		{
			{
				{
					id = "icon",
					forced_height = 16,
					forced_width = 16,
					widget = wibox.widget.imagebox
				},
				valign = "center",
				layout = wibox.container.place
			},
			{
				id = "txt",
				widget = wibox.widget.textbox
			},
			spacing = 4,
			layout = wibox.layout.fixed.horizontal,
		},
		margins = 4,
		layout = wibox.container.margin,
	},
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 4)
	end,
	widget = wibox.container.background,
	set_text = function(self, new_value)
		self:get_children_by_id("txt")[1].text = new_value
	end,
	set_icon = function(self, new_value)
		self:get_children_by_id("icon")[1].image = new_value
	end
}

local popup = awful.popup {
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

function notification_center_widget:update_counter(notifications)
	local notification_count = 0
	for _, p in ipairs(notifications) do
		if not p.status then
			notification_count = notification_count + 1
		end
	end

	notification_center_widget.widget.set_text(notification_count)
end

local function worker(user_args)
	local args = user_args or {}
	local icon = args.icon or ICONS_DIR .. "/stock_bell.svg"

	notification_center_widget.widget:set_icon(icon)
	notification_center_widget.widget:set_text(0)

	naughty.connect_signal("added", function()
		notification_center_widget.widget:set_text(1)
	end)

	function update_widget()
		for i = 0, #rows do rows[i] = nil end

		local first_row = wibox.widget {
			{
				{ widget = wibox.widget.textbox },
				{
					markup = '<span size="large" font_weight="bold" color="' ..
						beautiful.fg_normal .. '">Notifications</span>',
					align = 'center',
					forced_width = 350,
					forced_height = 40,
					widget = wibox.widget.textbox
				},
				spacing = 8,
				layout = wibox.layout.fixed.horizontal
			},
			bg = beautiful.bg_normal,
			widget = wibox.container.background
		}

		table.insert(rows, first_row)

		popup:setup(rows)
	end

	update_widget()
	notification_center_widget.widget:buttons(
		gears.table.join(
			awful.button({}, 1, function()
				if popup.visible then
					notification_center_widget.widget:set_bg("#00000000")
					popup.visible = not popup.visible
				else
					notification_center_widget.widget:set_bg(beautiful.bg_focus)
					popup:move_next_to(mouse.current_widget_geometry)
				end
			end)
		)
	)

	return notification_center_widget.widget
end

return setmetatable(notification_center_widget, { __call = function(_, ...) return worker(...) end })
