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
M.clear_selected = false
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

M.dismiss = function(notif)
	M.notifications[notif.id] = nil
	M.rebuild_popup()
	if #M.rows == 1 then
		M.notification_center.widget:set_bg("#00000000")
		M.popup.visible = not M.popup.visible
	end
end

M.build_row = function(notif)
	local row = wibox.widget {
		{
			{
				layout = wibox.container.margin,
				top = 5,
				bottom = 5,
				{
					layout = wibox.layout.stack,
					{
						layout = wibox.layout.align.horizontal,
						{
							layout = wibox.container.margin,
							left = 10,
							{
								widget = wibox.widget.textbox,
								font = beautiful.notif_font,
								text = notif.title,
								align = 'left',
								valign = 'bottom',
							},
						},
						{
							layout = wibox.container.margin,
							left = 10,
							{
								widget = wibox.widget.textbox,
								text = os.date("%H:%M"),
								align = 'left',
								valign = 'bottom',
							},
						},
						{
							layout = wibox.container.margin,
							right = 10,
							{
								id = "dismiss",
								widget = wibox.container.background,
								shape = gears.shape.rounded_bar,
								forced_width = 20,
								{
									widget = wibox.widget.imagebox,
									image = M.dismiss_icon,
									forced_height = 20,
									forced_width = 20,
									valign = "center",
								}
							}
						}
					}
				}
			},
			{
				layout = wibox.container.margin,
				bottom = 5,
				{
					layout = wibox.container.margin,
					left = 10,
					right = 10,
					{
						widget = wibox.widget.textbox,
						text = notif.text,
						align = 'left',
						forced_width = 400,
						ellipsize = "end",
						wrap = "word"
					},
				},
			},
			layout = wibox.layout.fixed.vertical,
		},
		bg = beautiful.bg_normal,
		widget = wibox.container.background
	}

	-- row:connect_signal("button::press", function() M.dismiss(notif) end)
	-- row:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
	-- row:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)


	local dismiss_button = row:get_children_by_id("dismiss")[1]
	dismiss_button:connect_signal("button::press", function(c) M.dismiss(notif) end)
	dismiss_button:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
	dismiss_button:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)

	return row
end

M.rebuild_popup = function()
	local function get_clear_bg()
		if M.clear_selected then
			return beautiful.bg_focus
		else
			return beautiful.bg_normal
		end
	end

	M.rows = {
		layout = wibox.layout.fixed.vertical,
		spacing = 1,
		spacing_widget = wibox.widget.separator,
	}

	local first_row = wibox.widget {
		layout = wibox.container.margin,
		top = 8,
		bottom = 10,
		{
			layout = wibox.layout.stack,
			{
				layout = wibox.layout.align.horizontal,
				nil,
				nil,
				{
					layout = wibox.container.margin,
					right = 10,
					{
						id = "clear",
						widget = wibox.container.background,
						forced_width = 70,
						bg = get_clear_bg(),
						shape = gears.shape.rounded_rect,
						{
							valign = "bottom",
							halign = "center",
							widget = wibox.widget.textbox,
							text = "Clear",
							font = beautiful.font,
						}
					}
				}
			},
			{
				layout = wibox.container.place,
				valign = "center",
				halign = "center",
				{
					text = "Notifications",
					font = beautiful.title_font,
					valign = "bottom",
					halign = "center",
					forced_width = 400,
					widget = wibox.widget.textbox,
				}
			}
		}
	}

	local clear_button = first_row:get_children_by_id("clear")[1]
	clear_button:connect_signal("button::press", function()
		M.notifications = {}
		M.clear_selected = false
		M.notification_center.widget:set_bg("#00000000")
		M.popup.visible = not M.popup.visible
		M.rebuild_popup()
	end)
	clear_button:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
	clear_button:connect_signal("mouse::leave", function(c)
		c:set_bg(beautiful.bg_normal)
		M.clear_selected = false
	end)
	table.insert(M.rows, first_row)

	for _, notif in pairs(M.notifications) do
		local row = M.build_row(notif)
		table.insert(M.rows, row)
	end

	M.notification_center.widget:set_text(#M.rows - 1)
	if #M.rows > 1 then
		M.notification_center.widget:set_icon(M.icon)
	else
		M.notification_center.widget:set_icon(M.empty_icon)
	end
	M.popup:setup(M.rows)
end

M.setup = function(user_args)
	local args = user_args or {}
	M.stop_display = args.stop_display or true
	M.empty_icon = args.empty_icon or ICONS_DIR .. "/bell_none.png"
	M.icon = args.icon or ICONS_DIR .. "/bell.png"
	M.dismiss_icon = args.dismiss_icon or ICONS_DIR .. "/trash.svg"

	M.notification_center.widget:set_icon(M.icon)
	M.notification_center.widget:set_text(0)

	if M.stop_display then
		naughty.connect_signal("request::display", function(notif)
			notif.ignore = true
		end)
	end

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
