local colours          = require("themes.tokyonight.colours")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

theme.font             = "RobotoMono Nerd Font 10"
theme.taglist_font     = "RobotoMono Nerd Font Bold 10"
theme.notif_font       = "RobotoMono Nerd Font Bold 12"
theme.title_font       = "RobotoMono Nerd Font Bold 14"

theme.bg_normal        = colours.color['Night']
theme.bg_focus         = colours.color['Terminal Black']
theme.bg_urgent        = colours.color['Orange']
theme.bg_minimize      = colours.color['Green']
theme.bg_systray       = colours.color['Night']

theme.fg_normal        = colours.color['Editor Foreground']
theme.fg_focus         = colours.color['Editor Foreground']
theme.fg_urgent        = colours.color['Editor Foreground']
theme.fg_minimize      = colours.color['Terminal Black']

theme.useless_gap      = 10
theme.border_width     = 1

theme.border_normal    = colours.color['Terminal Black']
theme.border_focus     = colours.color['Light Blue 2']
theme.border_marked    = colours.color['Green']

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:

theme.taglist_bg_focus = colours.color['Night']
--theme.taglist_bg_focus = "png:" .. theme_path .. "misc/copycat-holo/taglist_bg_focus.png"
theme.taglist_fg_focus = colours.color['Light Blue 2']


theme.tasklist_bg_normal     = colours.color['Night']
--theme.tasklist_bg_normal = "png:" .. theme_path .. "misc/copycat-holo/bg_focus.png"
theme.tasklist_bg_focus      = colours.color['Night']
--theme.tasklist_bg_focus   = "png:" .. theme_path .. "misc/copycat-holo/bg_focus_noline.png"
theme.tasklist_fg_focus      = colours.color['Light Blue 2']

theme.titlebar_bg_normal     = colours.color['Night']
theme.titlebar_bg_focus      = colours.color['Storm']
theme.titlebar_fg_focus      = colours.color['Editor Foreground']

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon      = theme_path .. "misc/default/submenu.png"

theme.menu_height            = 25
theme.menu_width             = 200
theme.menu_context_height    = 20

theme.menu_bg_normal         = colours.color['Night']
theme.menu_bg_focus          = colours.color['Storm']
theme.menu_fg_focus          = colours.color['Editor Foreground']

theme.menu_border_color      = colours.color['Storm']
theme.menu_border_width      = 1

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"
theme.statusbar_spacing      = 10
theme.statusbar_border_color = colours.color["Terminal Black"]

theme.fg_red                 = colours.color["Terminal Red"]
