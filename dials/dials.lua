------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Light/dark colors
dark_colors = false

-- Font/color variables
main_color = dark_colors and 0x383c4a or 0xd3dae3
text_color = dark_colors and 0x21232b or 0xbac3cf
main_font = 'Ubuntu'

-- Dial colors
dials_attr = {
	fill_color = main_color,
	fill_alpha = 0.15,
	bg_color = main_color,
	bg_alpha = 0,
	fg_color = main_color,
	fg_alpha = dark_colors and 0.6 or 0.8
}

-- Text font/colors
text_attr = {
	label = { font = main_font, fontsize = 15, color = text_color, alpha = 1 },
	value = { font = main_font, fontsize = 24, color = main_color, alpha = 1 }
}

-- Dials
dials = {
	radius = 50, width = 10,
	start_angle = -180, end_angle = 180,
	gap_x = 50, gap_y = 0,
	gap_label = 20
}

------------------------------------------------------------------------------
-- DIAL VARIABLES
------------------------------------------------------------------------------
-- Index, label, suffix (default = '%'), name, arg (default = '')
dials_table = {
	core = {
		index = 0, text = 'Core Temp', suffix = '°C', name = 'acpitemp'
	},
	cpu = {
		index = 1, text = 'CPU', name = 'cpu', arg = 'cpu0'
	},
	ram = {
		index = 2, text = 'Memory', name = 'memperc'
	},
	home = {
		index = 3, text = 'Home', name = 'fs_used_perc', arg = '/home'
	},
	data = {
		index = 4, text = 'Data', name = 'fs_used_perc', arg = '/home/data'
	},
	battery = {
		index = 5, text = 'Battery', name = 'battery_percent'
	},
}

------------------------------------------------------------------------------
-- INITIALIZE TABLES VARIABLES
------------------------------------------------------------------------------
-- Get dial count
n_dials = 0
for i, dial in pairs(dials_table) do n_dials = n_dials + 1 end

-- Calculate x offset (to center rings)
dial_spacing = 2*dials.radius + dials.width + dials.gap_x
dial_x = -(n_dials/2 - 0.5)*dial_spacing

for i, dial in pairs(dials_table) do
	dial.r = dials.radius
	dial.w = dials.width
	dial.sa = dials.start_angle
	dial.ea = dials.end_angle
	dial.x = dial_x + dial.index*dial_spacing
	dial.y = dials.radius + dials.width/2 + dials.gap_y
	dial.fillc = dials_attr.fill_color
	dial.filla = dials_attr.fill_alpha
	dial.bgc = dials_attr.bg_color
	dial.bga = dials_attr.bg_alpha
	dial.fgc = dials_attr.fg_color
	dial.fga = dials_attr.fg_alpha
	dial.label = {
		y = dial.y + dial.r + dial.w/2 + dials.gap_label,
		font = text_attr.label.font,
		fs = text_attr.label.fontsize,
		color = text_attr.label.color,
		alpha = text_attr.label.alpha
	}
	dial.value = {
		y = dial.y,
		font = text_attr.value.font,
		fs = text_attr.value.fontsize,
		color = text_attr.value.color,
		alpha = text_attr.value.alpha
	}
end

------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'

------------------------------------------------------------------------------
-- AUXILIARY FUNCTIONS
------------------------------------------------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

function get_conky_value(name, arg)
	local str = string.format('${%s %s}', name, arg)
	str = conky_parse(str)

	local value = tonumber(str)
	if value == nil then value = 0 end

	return(value)
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_dial
---------------------------------------
function draw_dial(cr, pt)
	pt.arg = (pt.arg or '')
	pt.suffix = (pt.suffix or '%')

	local value = get_conky_value(pt.name, pt.arg)

	local pct = value/100
	pct = (pct > 1 and 1 or pct)

	local angle_0 = pt.sa*(2*math.pi/360) - math.pi/2
	local angle_f = pt.ea*(2*math.pi/360) - math.pi/2
	local t_arc = pct*(angle_f - angle_0)

	local dial_x = conky_window.width/2 + pt.x

	-- Draw background fill
	cairo_arc(cr, dial_x, pt.y, pt.r + pt.w/2, angle_0, angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.fillc, pt.filla))
	cairo_fill(cr)

	-- Draw background ring
	cairo_arc(cr, dial_x, pt.y, pt.r, angle_0, angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.bgc, pt.bga))
	cairo_set_line_width(cr, pt.w)
	cairo_stroke(cr)

	-- Draw indicator ring
	cairo_arc(cr, dial_x, pt.y, pt.r, angle_0, angle_0 + t_arc)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.fgc, pt.fga))
	cairo_stroke(cr)

	-- Draw value text
	cairo_select_font_face(cr, pt.value.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, pt.value.fs)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.value.color, pt.value.alpha))

	local value_text = value..pt.suffix

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, value_text, t_extents)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	cairo_move_to(cr, dial_x - t_extents.width*0.5 - t_extents.x_bearing*0.5, pt.value.y + f_extents.height/2 - f_extents.descent)
	cairo_show_text(cr, value_text)
	cairo_stroke(cr)

	-- Draw label text
	cairo_select_font_face(cr, pt.label.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, pt.label.fs)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.label.color, pt.label.alpha))

	cairo_text_extents(cr, pt.text, t_extents)
	cairo_font_extents(cr, f_extents)

	cairo_move_to(cr, dial_x - t_extents.width*0.5 - t_extents.x_bearing*0.5, pt.label.y + f_extents.height - f_extents.descent*2)
	cairo_show_text(cr, pt.text)
	cairo_stroke(cr)
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	for id, dial in pairs(dials_table) do
		draw_dial(cr, dial)
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
