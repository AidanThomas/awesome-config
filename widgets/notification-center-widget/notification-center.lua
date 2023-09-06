local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. "/.config/awesome/widgets/notification-center-widget"
local ICONS_DIR = WIDGET_DIR .. "/icons/"

local M = {}

M.notifications = {}
M.rows = { layout = wibox.layout.fixed.vertical }
M.notification_center = {}
M.notification_center.widget = wibox.widget {
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
	for i = 1, #M.rows do M.rows[i] = nil end
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
	table.insert(M.rows, first_row)

	for _, notif in pairs(M.notifications) do
		local row = wibox.widget {
			{
				{ widget = wibox.widget.textbox },
				{
					text = notif.text,
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
		table.insert(M.rows, row)
	end

	M.notification_center.widget:set_text(#M.rows - 1)
	M.popup:setup(M.rows)
end

M.setup = function(user_args)
	local args = user_args or {}
	local icon = args.icon or ICONS_DIR .. "/stock_bell.svg"

	M.notification_center.widget:set_icon(icon)
	M.notification_center.widget:set_text(0)

	M.rebuild_popup()

	naughty.connect_signal("added", function(notif)
		if M.notifications[notif.id] ~= nil then
			return
		else
			M.notifications[notif.id] = notif
			M.rebuild_popup()
		end
	end)


	M.notification_center.widget:buttons(
		gears.table.join(
			awful.button({}, 1, function()
				if M.popup.visible then
					M.notification_center.widget:set_bg("#00000000")
					M.popup.visible = not M.popup.visible
				else
					M.notification_center.widget:set_bg(beautiful.bg_focus)
					M.popup:move_next_to(mouse.current_widget_geometry)
				end
			end)
		)
	)

	return M.notification_center.widget
end

return M
