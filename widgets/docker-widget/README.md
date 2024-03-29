# Docker / Podman Widget
The widget allows to manage docker and podman containers, namely start/stop/pause/unpause:

<p align="center">
    <img src="https://github.com/streetturtle/awesome-wm-widgets/raw/master/docker-widget/docker.gif"/>
</p>

## Customization

It is possible to customize widget by providing a table with all or some of the following config parameters:

| Name | Default | Description |
|---|---|---|
| `icon` | `./docker-widget/icons/docker.svg` | Path to the icon |
| `number_of_containers` | `-1` | Number of last created containers to show |
| `executable_name` | `docker` | Name of the executable to use, defaults to `docker` |
| `max_widget_width` | 270 | Maximum width of the widget before the text breaks |

The `executable_name` allows you to use `Podman` instead of docker. This works since `Podman` is compatible to `docker` in the sense that the syntax and command outputs are identical.

## Installation
```lua
local docker_widget = require("awesome-wm-widgets.docker-widget.docker")
...
s.mytasklist, -- Middle widget
	{ -- Right widgets
    	layout = wibox.layout.fixed.horizontal,
        ...
        -- default
        docker_widget(),
        -- customized
        docker_widget{
            number_of_containers = 5
        },
```
