------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Light/dark colors
dark_colors = false

-- Font/color variables
main_color = dark_colors and 0x3d3846 or 0xdeddda
text_color = dark_colors and 0x241f31 or 0xc0bfbc
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
	radius = 48, width = 8,
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
		index = 0, label = 'Temperature', suffix = '°C', name = 'acpitemp'
	},
	cpu = {
		index = 1, label = 'CPU', name = 'cpu', arg = 'cpu0'
	},
	ram = {
		index = 2, label = 'Memory', name = 'memperc'
	},
	home = {
		index = 4, label = 'Home', name = 'fs_used_perc', arg = '/home'
	},
	root = {
		index = 3, label = 'Root', name = 'fs_used_perc', arg = '/'
	},
	battery = {
		index = 5, label = 'Battery', name = 'battery_percent'
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
	dial.label_y = dial.y + dial.r + dial.w/2 + dials.gap_label

	dial.attr = dials_attr
	dial.label_attr = text_attr.label
	dial.value_attr = text_attr.value
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
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.fill_color, pt.attr.fill_alpha))
	cairo_fill(cr)

	-- Draw background ring
	cairo_arc(cr, dial_x, pt.y, pt.r, angle_0, angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.bg_color, pt.attr.bg_alpha))
	cairo_set_line_width(cr, pt.w)
	cairo_stroke(cr)

	-- Draw indicator ring
	cairo_arc(cr, dial_x, pt.y, pt.r, angle_0, angle_0 + t_arc)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.fg_color, pt.attr.fg_alpha))
	cairo_stroke(cr)

	-- Draw value text
	cairo_select_font_face(cr, pt.value_attr.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, pt.value_attr.fontsize)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.value_attr.color, pt.value_attr.alpha))

	local value_text = value..pt.suffix

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, value_text, t_extents)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	cairo_move_to(cr, dial_x - t_extents.width*0.5 - t_extents.x_bearing*0.5, pt.y + f_extents.height/2 - f_extents.descent)
	cairo_show_text(cr, value_text)
	cairo_stroke(cr)

	-- Draw label text
	cairo_select_font_face(cr, pt.label_attr.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, pt.label_attr.fontsize)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.label_attr.color, pt.label_attr.alpha))

	cairo_text_extents(cr, pt.label, t_extents)
	cairo_font_extents(cr, f_extents)

	cairo_move_to(cr, dial_x - t_extents.width*0.5 - t_extents.x_bearing*0.5, pt.label_y + f_extents.height - f_extents.descent*2)
	cairo_show_text(cr, pt.label)
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
