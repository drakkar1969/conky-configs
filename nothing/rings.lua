------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require('cairo')
require('cairo_xlib')

package.path = package.path..';'..string.gsub(conky_config, 'rings.conf', '?.lua')
local lib = require('common')

------------------------------------------------------------------------------
-- CONSTANTS (DO NOT DELETE)
------------------------------------------------------------------------------
local init_done = false

local accent_color = nil

local layouts = {
	ROW = 0,
	COLUMN = 1,
	BOX = 2
}

------------------------------------------------------------------------------
-- WIDGET DATA
------------------------------------------------------------------------------
local widget = {
	layout = layouts.COLUMN,
	halign = lib.halign.LEFT,
	valign = lib.valign.BOTTOM,
	margin = 20,
	rings = {
		start_angle = -90,
		end_angle = 90,
		padding_x = 0,
		outer_radius = 95,
		bg_color = lib.colors.default,
		bg_alpha = 0.1,
		fg_color = lib.colors.accent,
		fg_alpha = 1
	},
	items = {}
}

---------------------------------------
-- CPU widget
---------------------------------------
widget.items[1] = {
	heading = {
		label = 'CPU'
	},
	ring = {
		step = 9,
		mark_width = 12,
		mark_thickness = 5,
		mark_indent = 0,
		mark_outdent = 0,
		label = '${cpu cpu0}%',
		value = '${cpu cpu0}',
		value_max = 100,
	},
	text = {
		label = 'CORE',
		value = '${hwmon coretemp temp 1}°C'
	}
}

---------------------------------------
-- MEMORY widget
---------------------------------------
widget.items[2] = {
	heading = {
		label = 'MEMORY'
	},
	ring = {
		step = 9,
		mark_width = 12,
		mark_thickness = 5,
		mark_indent = 0,
		mark_outdent = 0,
		label = '${memperc}%',
		value = '${memperc}',
		value_max = 100,
	},
	text = {
		label = 'SWAP',
		value = '${swap}'
	}
}

---------------------------------------
-- DISK widget
---------------------------------------
local partition = '/home'

widget.items[3] = {
	heading = {
		label = 'DISK'
	},
	ring = {
		step = 9,
		mark_width = 12,
		mark_thickness = 5,
		mark_indent = 0,
		mark_outdent = 0,
		label = '${fs_used_perc '..partition..'}%',
		value = '${fs_used_perc '..partition..'}',
		value_max = 100,
	},
	text = {
		label = 'IO',
		value = '${diskio}'
	}
}

---------------------------------------
-- WIFI widget
---------------------------------------
local interface = 'wlp0s20f3'
local wifi_max = 36000

widget.items[4] = {
	heading = {
		label = 'WIRELESS'
	},
	ring = {
		step = 9,
		mark_width = 12,
		mark_thickness = 5,
		mark_indent = 0,
		mark_outdent = 0,
		label = '${downspeed '..interface..'}',
		value = '${downspeedf '..interface..'}',
		value_max = wifi_max,
	},
	text = {
		label = '${wireless_essid '..interface..'}',
		value = ''
	}
}

------------------------------------------------------------------------------
-- INITIALIZATION FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function init_widgets
---------------------------------------
function init_widgets()
	-- Calculate item width and height
	local item_w = (lib.bg.padding_x + widget.rings.padding_x + widget.rings.outer_radius) * 2
	local item_h = lib.fonts.heading.height + lib.line_spacing * 3.5 + widget.rings.outer_radius + lib.fonts.text.height + lib.bg.padding_y * 2

	-- Calculate widget x,y coordinates
	local x = 0
	local y = 0

	if widget.layout == layouts.COLUMN then
		if widget.halign == lib.halign.CENTER then
			x = (conky_window.width - item_w)/2
		elseif widget.halign == lib.halign.RIGHT then
			x = conky_window.width - item_w
		end

		if widget.valign == lib.valign.MIDDLE then
			y = (conky_window.height - item_h * #widget.items - widget.margin * (#widget.items - 1))/2
		elseif widget.valign == lib.valign.BOTTOM then
			y = conky_window.height - item_h * #widget.items - widget.margin * (#widget.items - 1)
		end
	elseif widget.layout == layouts.BOX then
		if widget.halign == lib.halign.CENTER then
			x = (conky_window.width - item_w * 2 - widget.margin)/2
		elseif widget.halign == lib.halign.RIGHT then
			x = conky_window.width - item_w * 2 - widget.margin
		end

		if widget.valign == lib.valign.MIDDLE then
			y = (conky_window.height - item_h * 2 - widget.margin)/2
		elseif widget.valign == lib.valign.BOTTOM then
			y = conky_window.height - item_h * 2 - widget.margin
		end
	else
		if widget.halign == lib.halign.CENTER then
			x = (conky_window.width - item_w * #widget.items - widget.margin * (#widget.items - 1))/2
		elseif widget.halign == lib.halign.RIGHT then
			x = conky_window.width - item_w * #widget.items - widget.margin * (#widget.items - 1)
		end

		if widget.valign == lib.valign.MIDDLE then
			y = (conky_window.height - item_h)/2
		elseif widget.valign == lib.valign.BOTTOM then
			y = conky_window.height - item_h
		end
	end

	-- Calculate item data
	for i, item in ipairs(widget.items) do
		item.width = item_w
		item.height = item_h

		if widget.layout == layouts.COLUMN then
			item.x = x
			item.y = y + (i - 1) * (item_h + widget.margin)
		elseif widget.layout == layouts.BOX then
			item.x = x + (i%2 == 1 and 0 or item_w + widget.margin)
			item.y = y + (i <= 2 and 0 or item_h + widget.margin)
		else
			item.x = x + (i - 1) * (item_w + widget.margin)
			item.y = y
		end

		item.ring.start_angle = widget.rings.start_angle
		item.ring.end_angle = widget.rings.end_angle
		item.ring.padding_x = widget.rings.padding_x
		item.ring.outer_radius = widget.rings.outer_radius
		item.ring.bg_color = widget.rings.bg_color
		item.ring.bg_alpha = widget.rings.bg_alpha
		item.ring.fg_color = widget.rings.fg_color
		item.ring.fg_alpha = widget.rings.fg_alpha

		item.ring.inner_radius = item.ring.outer_radius - item.ring.mark_width - item.ring.mark_thickness

		item.heading.x = item.x + item_w/2
		item.heading.y = item.y + lib.bg.padding_y

		item.ring.x = item.heading.x
		item.ring.y = item.heading.y + lib.fonts.heading.height + lib.line_spacing * 1.5 + item.ring.outer_radius

		item.text.xs = item.x + lib.bg.padding_x
		item.text.xe = item.x + item_w - lib.bg.padding_x
		item.text.y = item.ring.y + lib.line_spacing * 2
	end
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	local updates = tonumber(conky_parse('${updates}'))

	if conky_window == nil then return end

	if updates < 2 then return end

	-- Create cairo context
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Update accent color if necessary
	local xprop_color = lib.get_xprop_accent()

	if xprop_color ~= accent_color then
		accent_color = xprop_color

		lib.update_font_colors(accent_color)

		widget.rings.fg_color = accent_color

		for _, item in pairs(widget.items) do
			item.ring.fg_color = accent_color
		end
	end

	-- Initialize
	if init_done == false then
		lib.init_fonts(cr)
		init_widgets()

		init_done = true
	end

	for i, w in pairs(widget.items) do
		-- Draw background
		lib.draw_background(cr, w)

		-- Draw header
		lib.draw_text(cr, lib.fonts.heading, lib.halign.CENTER, w.heading.x, w.heading.y, w.heading.label)

		-- Draw ring with label
		lib.draw_ring(cr, w.ring)

		-- Draw text
		lib.draw_text(cr, lib.fonts.text, lib.halign.LEFT, w.text.xs, w.text.y, w.text.label, w.text.xe - w.text.xs)
		lib.draw_text(cr, lib.fonts.text, lib.halign.RIGHT, w.text.xe, w.text.y, w.text.value, w.text.xe - w.text.xs)
	end

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
