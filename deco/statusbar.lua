-- Standard awesome library
local gears           = require("gears")
local awful           = require("awful")
local beautiful       = require("beautiful")

-- Wibox handling library
local wibox           = require("wibox")

-- Custom Local Library: Common Functional Decoration
local deco            = {
	wallpaper = require("deco.wallpaper"),
	taglist   = require("deco.taglist"),
	tasklist  = require("deco.tasklist")
}

local taglist_buttons = deco.taglist()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- {{{ Wibar
-- Create a textclock widget
mytextclock           = wibox.widget.textclock("%a %b %_d   %H:%M")

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()

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
					s.mypromptbox,
				},
				nil,
				{
					-- Right widgets
					layout = wibox.layout.fixed.horizontal,
					{
						layout = wibox.container.margin,
						right = 20,
						s.mylayoutbox,
					}
				},
			},
			{
				mytextclock,
				valign = "center",
				halighn = "center",
				layout = wibox.container.place,
			}
		}
	}
end)
-- }}}