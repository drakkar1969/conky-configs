------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'

local path = string.gsub(conky_config, 'rings.conf', '?.lua')
package.path = package.path..';'..path
local lib = require 'common'

------------------------------------------------------------------------------
-- CONSTANTS (DO NOT DELETE)
------------------------------------------------------------------------------
local init_done = false

local layouts = {
	ROW = 0,
	COLUMN = 1,
	BOX = 2
}

------------------------------------------------------------------------------
-- WIDGET DATA
------------------------------------------------------------------------------
local widgets = {}

local widgets_style = {
	layout = layouts.BOX,
	margin = 20
}

---------------------------------------
-- CPU widget
---------------------------------------
widgets.cpu = {
	index = 1,
	heading = {
		label = 'CPU'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${cpu cpu0}%',
		value = '${cpu cpu0}',
		value_max = 100,
		bg_color = lib.colors.default,
		bg_alpha = 0.05,
		fg_color = lib.colors.accent,
		fg_alpha = 1
	},
	text = {
		items = {
			{ label = 'CORE', value = '${hwmon coretemp temp 1}°C' }
		}
	}
}

---------------------------------------
-- MEMORY widget
---------------------------------------
widgets.mem = {
	index = 2,
	heading = {
		label = 'MEMORY'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${memperc}%',
		value = '${memperc}',
		value_max = 100,
		bg_color = lib.colors.default,
		bg_alpha = 0.05,
		fg_color = lib.colors.accent,
		fg_alpha = 1
	},
	text = {
		items = {
			{ label = 'SWAP', value = '${swap}' }
		}
	}
}

---------------------------------------
-- DISK widget
---------------------------------------
widgets.disk = {
	index = 3,
	heading = {
		label = 'DISK'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${fs_used_perc /home}%',
		value = '${fs_used_perc /home}',
		value_max = 100,
		bg_color = lib.colors.default,
		bg_alpha = 0.05,
		fg_color = lib.colors.accent,
		fg_alpha = 1
	},
	text = {
		items = {
			{ label = 'IO', value = '${diskio}' }
		}
	}
}

---------------------------------------
-- WIFI widget
---------------------------------------
local interface = 'wlp0s20f3'
local wifi_max = 36000

widgets.wifi = {
	index = 4,
	heading = {
		label = 'WIRELESS'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${downspeed '..interface..'}',
		value = '${downspeedf '..interface..'}',
		value_max = wifi_max,
		bg_color = lib.colors.default,
		bg_alpha = 0.05,
		fg_color = lib.colors.accent,
		fg_alpha = 1
	},
	text = {
		items = {
			{ label = '${wireless_essid '..interface..'}', value = '' }
		}
	}
}

------------------------------------------------------------------------------
-- INITIALIZATION FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function init_widget
---------------------------------------
function init_widget()
	for i, w in pairs(widgets) do
		w.width = (lib.bg.padding_x + w.ring.padding_x + w.ring.outer_radius) * 2
		w.height = lib.fonts.heading.height + lib.line_spacing * 2 + w.ring.outer_radius + (lib.line_spacing + lib.fonts.text.height) * #w.text.items + lib.bg.padding_y * 2

		if widgets_style.layout == layouts.COLUMN then
			w.x = 0
			w.y = (w.index - 1) * (w.height + widgets_style.margin)
		elseif widgets_style.layout == layouts.BOX then
			w.x = (w.index%2 == 1 and 0 or w.width + widgets_style.margin)
			w.y = (w.index <= 2 and 0 or w.height + widgets_style.margin)
		else
			w.x = (w.index - 1) * (w.width + widgets_style.margin)
			w.y = 0
		end

		w.heading.x = w.x + w.width/2
		w.heading.y = w.y + lib.bg.padding_y

		w.ring.x = w.heading.x
		w.ring.y = w.heading.y + lib.line_spacing * 2 + w.ring.outer_radius

		w.ring.inner_radius = w.ring.outer_radius - w.ring.mark_width - w.ring.mark_thickness

		w.text.xs = w.x + lib.bg.padding_x
		w.text.xe = w.x + w.width - lib.bg.padding_x
	end
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Create cairo context
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Update accent color if necessary
	local xprop_color = lib.get_xprop_accent()

	if xprop_color ~= accent_color then
		accent_color = xprop_color

		lib.update_font_colors(accent_color)

		for i, w in pairs(widgets) do
			w.ring.fg_color = accent_color
		end
	end

	-- Initialize
	if init_done == false then
		lib.init_fonts(cr)
		init_widget()

		init_done = true
	end

	for i, w in pairs(widgets) do
		-- Draw background
		lib.draw_background(cr, w)

		-- Draw header
		lib.draw_text(cr, lib.fonts.heading, lib.halign.CENTER, w.heading.x, w.heading.y, w.heading.label)

		-- Draw ring with label
		lib.draw_ring(cr, w.ring, lib.fonts.ring)

		-- Draw text
		for i, item in pairs(w.text.items) do
			local y = w.ring.y + (lib.line_spacing + lib.fonts.text.height) * i

			lib.draw_text(cr, lib.fonts.text, lib.halign.LEFT, w.text.xs, y, item.label, w.text.xe - w.text.xs)
			lib.draw_text(cr, lib.fonts.text, lib.halign.RIGHT, w.text.xe, y, item.value, w.text.xe - w.text.xs)
		end
	end

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
