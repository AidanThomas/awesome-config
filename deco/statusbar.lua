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
local calendar            = require("widgets.calendar-widget.calendar")
local tray                = require("widgets.tray-widget.tray")

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

local cal_popup           = calendar.setup()

textclock:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
textclock:connect_signal("mouse::leave", function(c)
	if not calendar.calendar_open then
		c:set_bg(beautiful.bg_normal)
	end
end)
textclock:buttons(
	gears.table.join(
		awful.button({}, 1, function()
			if cal_popup.visible then
				cal_popup.visible = not cal_popup.visible
			else
				calendar.cal:set_date(nil)
				calendar.cal:set_date(os.date("*t"))
				cal_popup:move_next_to(mouse.current_widget_geometry)
			end
			calendar.calendar_open = not calendar.calendar_open
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

	-- Create the tray widget
	s.tray = tray.setup({
		icon = "/aidant/home/.config/awesome/widgets/icons/tray.png"
	})

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
					-- {
					-- 	layout = wibox.container.margin,
					-- 	left = 5,
					-- 	right = 5,
					-- 	s.tray
					-- },
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
