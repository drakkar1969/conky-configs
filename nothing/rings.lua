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

local ALIGNL, ALIGNC, ALIGNR = 0, 1, 2

local fonts = {}

local heading_color = 0xaaaaaa
local default_color = 0xffffff
local accent_color = 0xffc057

local background = {
	color = 0x28282c,
	border_radius = 36,
	padding_x = 40,
	padding_y = 40
}

local line_spacing = 22

------------------------------------------------------------------------------
-- WIDGET DATA
------------------------------------------------------------------------------
local widgets = {}

---------------------------------------
-- CPU widget
---------------------------------------
widgets.cpu = {
	x = 0,
	y = 0,
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
		bg_color = default_color,
		bg_alpha = 0.05,
		fg_color = accent_color,
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
	x = 296,
	y = 0,
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
		bg_color = default_color,
		bg_alpha = 0.05,
		fg_color = accent_color,
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
	x = 0,
	y = 318,
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
		bg_color = default_color,
		bg_alpha = 0.05,
		fg_color = accent_color,
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
	x = 296,
	y = 318,
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
		bg_color = default_color,
		bg_alpha = 0.05,
		fg_color = accent_color,
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
-- Function init_fonts
---------------------------------------
function init_fonts(cr)
	fonts = {
		heading = {
			face = 'Ndot 55', size = 36, stroke = 0, color = heading_color
		},
		ring = {
			face = 'Ndot 57', size = 32, stroke = 0.5, color = accent_color
		},
		text = {
			face = 'Inter', size = 25, stroke = 0.6, color = default_color
		},
	}

	-- Calculate font heights
	for k, font in pairs(fonts) do
		font.height = lib.font_height(cr, font)
	end
end

---------------------------------------
-- Function init_widget
---------------------------------------
function init_widget()
	for i, w in pairs(widgets) do
		w.width = (background.padding_x + w.ring.padding_x + w.ring.outer_radius) * 2
		w.height = fonts.heading.height + line_spacing + w.ring.outer_radius + (line_spacing + fonts.text.height) * #w.text.items + line_spacing * 2 + background.padding_y * 2

		w.heading.x = w.x + w.width/2
		w.heading.y = w.y + background.padding_y

		w.ring.x = w.heading.x
		w.ring.y = w.heading.y + line_spacing * 2 + w.ring.outer_radius

		w.ring.inner_radius = w.ring.outer_radius - w.ring.mark_width - w.ring.mark_thickness

		w.text.xs = w.x + background.padding_x
		w.text.xe = w.x + w.width - background.padding_x
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

	-- Initialize
	if init_done == false then
		init_fonts(cr)
		init_widget()

		init_done = true
	end

	for i, w in pairs(widgets) do
		-- Draw background
		lib.draw_background(cr, w, background)

		-- Draw header
		lib.draw_text(cr, fonts.heading, ALIGNC, w.heading.x, w.heading.y, w.heading.label)

		-- Draw ring with label
		lib.draw_ring(cr, w.ring, fonts.ring)

		-- Draw text
		for i, item in pairs(w.text.items) do
			local y = w.ring.y + line_spacing + (line_spacing + fonts.text.height) * i

			lib.draw_text(cr, fonts.text, ALIGNL, w.text.xs, y, item.label, w.text.xe - w.text.xs)
			lib.draw_text(cr, fonts.text, ALIGNR, w.text.xe, y, item.value, w.text.xe - w.text.xs)
		end
	end

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
