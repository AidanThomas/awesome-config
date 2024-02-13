local gears      = require("gears")
local beautiful  = require("beautiful")
local awful      = require("awful")
local wibox      = require("wibox")

local M          = {}

M.calendar_open  = false
M.styles         = {}
M.rounded_shape  = function(size, partial)
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

M.styles.month   = {
	padding  = 5,
	bg_color = beautiful.bg_normal,
	shape    = M.rounded_shape(10)
}
M.styles.normal  = {
	shape = M.rounded_shape(5),
	padding = 2,
}
M.styles.focus   = {
	fg_color     = beautiful.taglist_fg_focus,
	markup       = function(t) return '<b>' .. t .. '</b>' end,
	shape        = M.rounded_shape(5),
	border_width = 1,
	padding      = 1,
	border_color = beautiful.taglist_fg_focus
}
M.styles.header  = {
	fg_color = beautiful.fg_normal,
	bg_color = beautiful.bg_normal,
	markup   = function(t) return '<b>' .. t .. '</b>' end,
	shape    = M.rounded_shape(10)
}
M.styles.weekday = {
	fg_color     = beautiful.fg_normal,
	border_color = beautiful.bg_normal,
	markup       = function(t) return '<b>' .. t .. '</b>' end,
	shape        = M.rounded_shape(5)
}
M.decorate_cell  = function(widget, flag, date)
	if flag == "monthheader" and not M.styles.monthheader then
		flag = "header"
	end
	local props = M.styles[flag] or {}
	if props.markup and widget.get_text and widget.set_markup then
		widget:set_markup(props.markup(widget:get_text()))
	end
	-- Change bg color for weekends
	local d = { year = date.year, month = (date.month or 1), day = (date.day or 1) }
	local weekday = tonumber(os.date("%w", os.time(d)))
	local deafult_fg_color = (weekday == 0 or weekday == 6) and beautiful.fg_red or beautiful.fg_normal
	local ret = wibox.widget {
		{
			widget,
			margins = (props.padding or 2) + (props.border_width or 0),
			widget  = wibox.container.margin
		},
		shape        = props.shape,
		border_color = props.border_color or beautiful.bg_normal,
		border_width = props.border_width or 1,
		fg           = props.fg_color or deafult_fg_color,
		bg           = props.bg_color or beautiful.bg_normal,
		widget       = wibox.container.background
	}
	return ret
end

M.setup          = function()
	M.cal       = wibox.widget {
		date = os.date("*t"),
		fn_embed = M.decorate_cell, -- function to modify individual cells
		widget = wibox.widget.calendar.month
	}
	M.cal_popup = awful.popup {
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
					M.cal
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
	local next  = M.cal_popup.widget:get_children_by_id("next_month")[1]
	local prev  = M.cal_popup.widget:get_children_by_id("prev_month")[1]

	next:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
	next:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)
	next:connect_signal("button::press", function()
		local date = M.cal:get_date()
		local current = os.date("*t")
		date.month = date.month + 1
		if date.month == current.month and date.year == current.year then
			date.day = current.day
		else
			date.day = nil
		end
		M.cal:set_date(nil)
		M.cal:set_date(date)
	end)
	prev:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
	prev:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)
	prev:connect_signal("button::press", function()
		local date = M.cal:get_date()
		local current = os.date("*t")
		date.month = date.month - 1
		if date.month == current.month and date.year == current.year then
			date.day = current.day
		else
			date.day = nil
		end
		M.cal:set_date(nil)
		M.cal:set_date(date)
	end)

	return M.cal_popup
end

return M
