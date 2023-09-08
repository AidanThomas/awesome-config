-- Standard awesome library
local gears               = require("gears")
local awful               = require("awful")
local beautiful           = require("beautiful")

-- Wibox handling library
local wibox               = require("wibox")

-- Custom Local Library: Common Functional Decoration
local deco                = {
	wallpaper = require("deco.wallpaper"),
	taglist   = require("deco.taglist"),
	tasklist  = require("deco.tasklist")
}

local taglist_buttons     = deco.taglist()

-- Custom widgets
local volume_widget       = require("widgets.volume-widget.volume")
local spotify_widget      = require("widgets.spotify-widget.spotify")
local todo_widget         = require("widgets.todo-widget.todo")
local docker_widget       = require("widgets.docker-widget.docker")
local notification_center = require("widgets.notification-center-widget.notification-center")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- {{{ Wibar
-- Create a textclock widget
-- local mytextclock         = wibox.widget.textclock("%a %b %_d   %H:%M")
local textclock           = wibox.widget {
	widget = wibox.container.background,
	shape = function(cr, width, height)
		gears.shape.rounded_bar(cr, width, height, 4)
	end,
	{
		layout = wibox.container.margin,
		left = 10,
		right = 10,
		wibox.widget.textclock("%a %b %_d   %H:%M")
	}
}

local styles              = {}
local function rounded_shape(size, partial)
	if partial then
		return function(cr, width, height)
			gears.shape.partially_rounded_rect(cr, width, height,
				false, true, false, true, 5)
		end
	else
		return function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, size)
		end
	end
end
styles.month   = {
	padding      = 5,
	bg_color     = beautiful.bg_normal,
	border_width = 0,
	shape        = rounded_shape(10)
}
styles.normal  = {
	shape = rounded_shape(5),
	border_width = 1,
	border_color = beautiful.bg_normal
}
styles.focus   = {
	fg_color     = beautiful.taglist_fg_focus,
	markup       = function(t) return '<b>' .. t .. '</b>' end,
	shape        = rounded_shape(5, true),
	border_width = 1,
	border_color = beautiful.taglist_fg_focus
}
styles.header  = {
	fg_color = beautiful.fg_normal,
	bg_color = beautiful.bg_normal,
	markup   = function(t) return '<b>' .. t .. '</b>' end,
	shape    = rounded_shape(10)
}
styles.weekday = {
	fg_color = beautiful.fg_normal,
	markup   = function(t) return '<b>' .. t .. '</b>' end,
	shape    = rounded_shape(5)
}
local function decorate_cell(widget, flag, date)
	if flag == "monthheader" and not styles.monthheader then
		flag = "header"
	end
	local props = styles[flag] or {}
	if props.markup and widget.get_text and widget.set_markup then
		widget:set_markup(props.markup(widget:get_text()))
	end
	-- Change bg color for weekends
	local d = { year = date.year, month = (date.month or 1), day = (date.day or 1) }
	local weekday = tonumber(os.date("%w", os.time(d)))
	local default_bg = (weekday == 0 or weekday == 6) and beautiful.bg_focus or beautiful.bg_normal
	local ret = wibox.widget {
		{
			widget,
			margins = (props.padding or 2) + (props.border_width or 0),
			widget  = wibox.container.margin
		},
		shape        = props.shape,
		border_color = props.border_color or beautiful.border_normal,
		border_width = props.border_width or 0,
		fg           = props.fg_color or beautiful.fg_normal,
		bg           = props.bg_color or default_bg,
		widget       = wibox.container.background
	}
	return ret
end
local calendar_open = false
local cal           = wibox.widget {
	date = os.date("*t"),
	fn_embed = decorate_cell, -- function to modify individual cells
	widget = wibox.widget.calendar.month
}
local cal_popup     = awful.popup {
	widget = {
		layout = wibox.layout.fixed.vertical,
		{
			layout = wibox.container.margin,
			top = 10,
			{
				layout = wibox.layout.flex.horizontal,
				{
					layout = wibox.container.background,
					shape = gears.shape.rounded_bar,
					id = "prev_month",
					{
						widget = wibox.widget.textbox,
						font = beautiful.font,
						text = "",
						halign = 'center',
						valign = 'bottom'
					}
				},
				{
					layout = wibox.container.background,
					shape = gears.shape.rounded_bar,
					id = "next_month",
					{
						widget = wibox.widget.textbox,
						font = beautiful.font,
						text = "",
						halign = 'center',
						valign = 'bottom'
					}
				}
			}
		},
		{
			layout = wibox.container.margin,
			left = 10,
			right = 10,
			bottom = 10,
			{
				id = "calendar",
				layout = wibox.container.background,
				cal
			}
		}
	},
	bg = beautiful.bg_normal,
	ontop = true,
	visible = false,
	shape = gears.shape.rounded_rect,
	border_width = 1,
	border_color = beautiful.bg_focus,
	maximum_width = 400,
	offset = { x = 35, y = 5 },
}

local next          = cal_popup.widget:get_children_by_id("next_month")[1]
local prev          = cal_popup.widget:get_children_by_id("prev_month")[1]

next:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
next:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)
next:connect_signal("button::press", function()
	local date = cal:get_date()
	local current = os.date("*t")
	date.month = date.month + 1
	if date.month == current.month and date.year == current.year then
		date.day = current.day
	else
		date.day = nil
	end
	cal:set_date(nil)
	cal:set_date(date)
end)
prev:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
prev:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)
prev:connect_signal("button::press", function()
	local date = cal:get_date()
	local current = os.date("*t")
	date.month = date.month - 1
	if date.month == current.month and date.year == current.year then
		date.day = current.day
	else
		date.day = nil
	end
	cal:set_date(nil)
	cal:set_date(date)
end)

textclock:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
textclock:connect_signal("mouse::leave", function(c)
	if not calendar_open then
		c:set_bg(beautiful.bg_normal)
	end
end)
textclock:buttons(
	gears.table.join(
		awful.button({}, 1, function()
			if cal_popup.visible then
				cal_popup.visible = not cal_popup.visible
			else
				cal:set_date(nil)
				cal:set_date(os.date("*t"))
				cal_popup:move_next_to(mouse.current_widget_geometry)
			end
			calendar_open = not calendar_open
		end)
	)
)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function() awful.layout.inc(1) end),
		awful.button({}, 3, function() awful.layout.inc(-1) end),
		awful.button({}, 4, function() awful.layout.inc(1) end),
		awful.button({}, 5, function() awful.layout.inc(-1) end)
	))

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		layout  = {
			layout = wibox.layout.fixed.horizontal,
			spacing = 2,
		}
	}

	-- Create the volume widget
	s.volume = volume_widget({
		mixer_cmd = "pavucontrol",
		step = 5,
		widget_type = "icon_and_text",
		device = "pulse",
	})

	-- Create the spotify widget
	s.spotify = spotify_widget({
		max_length = 20,
		dim_when_paused = true,
		play_icon = os.getenv("HOME") .. "/.config/awesome/custom_icons/spotify.svg",
		pause_icon = os.getenv("HOME") .. "/.config/awesome/custom_icons/spotify_colourless.svg",
		font = beautiful.font,
	})

	-- Create todo widget
	s.todo = todo_widget()

	-- Create docker widget
	s.docker = docker_widget({
		icon = os.getenv("HOME") .. "/.config/awesome/custom_icons/docker.svg",
	})

	-- Create the notification center widget
	s.notification_center = notification_center.setup({})

	-- Create the wibox
	s.mywibox = awful.wibar({
		stretch = false,
		position = nil,
		width = screen[1].geometry.width * 0.985,
		height = 40,
		border_width = beautiful.statusbar_spacing,
		ontop = false,
		visible = true,
		opacity = 1,
		y_offset = 10,
		type = "normal",
		shape = gears.shape.rounded_bar,
		screen = s,
	})

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.container.background,
		shape = gears.shape.rounded_bar,
		shape_border_width = 1,
		shape_border_color = beautiful.statusbar_border_color,
		{
			layout = wibox.layout.stack,
			{
				layout = wibox.layout.align.horizontal,
				{
					layout = wibox.layout.fixed.horizontal,
					{
						layout = wibox.container.margin,
						left = 20,
						right = 10,
						s.mytaglist,
					},
				},
				nil,
				{
					-- Right widgets
					layout = wibox.layout.fixed.horizontal,
					{
						layout = wibox.container.margin,
						left = 20,
						right = 20,
						s.spotify
					},
					{
						layout = wibox.container.margin,
						left = 10,
						right = 5,
						s.docker
					},
					{
						layout = wibox.container.margin,
						left = 5,
						right = 5,
						s.notification_center
					},
					{
						layout = wibox.container.margin,
						left = 5,
						right = 5,
						s.todo
					},
					{
						layout = wibox.container.margin,
						left = 5,
						right = 20,
						s.volume
					},
				},
			},
			{
				textclock,
				valign = "center",
				halighn = "center",
				layout = wibox.container.place,
			}
		}
	}
end)
-- }}}
