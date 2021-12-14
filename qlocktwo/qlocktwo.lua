------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Light/dark colors
dark_colors = false

-- Font/color variables
clock_font = 'Hack'
clock_fontsize = 30
attr_on = dark_colors and { color = 0x383c4a, alpha = 1 } or { color = 0xd3dae3, alpha = 1 }
attr_off = dark_colors and { color = 0x383c4a, alpha = 0.25 } or { color = 0xd3dae3, alpha = 0.15 }

-- Row spacing
row_spacing = 45

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

------------------------------------------------------------------------------
-- BUILD TEXT TABLE
------------------------------------------------------------------------------
function add_text(table, i, j, txt, attr)
	table[i..j] = { text = txt, row = i, col = j, color = attr.color, alpha = attr.alpha }

	return (j + #txt)
end

function build_text_table()
	local table = {}

	-- Get current time (mins/hours)
	local min = tonumber(os.date('%M'))
	local hour = tonumber(os.date('%I'))

	-- Adjust hour if time is "to"
	if min >= 35 then hour = hour + 1 end

	-- Build text table
	local i, j = 0, 0

	j = add_text(table, i, j, "I T ", attr_on)
	j = add_text(table, i, j, "L ", attr_off)
	j = add_text(table, i, j, "I S ", attr_on)
	j = add_text(table, i, j, "A S T I M E ", attr_off)

	i, j = 1, 0
	
	j = add_text(table, i, j, "A ", ((min >=15 and min < 20) or (min >=45 and min < 50)) and attr_on or attr_off)
	j = add_text(table, i, j, "C ", attr_off)
	j = add_text(table, i, j, "Q U A R T E R ", ((min >=15 and min < 20) or (min >=45 and min < 50)) and attr_on or attr_off)
	j = add_text(table, i, j, "D C ", attr_off)

	i, j = 2, 0

	j = add_text(table, i, j, "T W E N T Y ", ((min >=20 and min < 30) or (min >=35 and min < 45)) and attr_on or attr_off)
	j = add_text(table, i, j, "F I V E ", ((min >=25 and min < 30) or (min >=5 and min < 10) or (min >=35 and min < 40) or (min >=55)) and attr_on or attr_off)
	j = add_text(table, i, j, "X ", attr_off)

	i, j = 3, 0

	j = add_text(table, i, j, "H A L F ", (min >=30 and min < 35) and attr_on or attr_off)
	j = add_text(table, i, j, "B ", attr_off)
	j = add_text(table, i, j, "T E N ", ((min >=10 and min < 15) or (min >= 50 and min < 55)) and attr_on or attr_off)
	j = add_text(table, i, j, "F ", attr_off)
	j = add_text(table, i, j, "T O ", (min >= 35) and attr_on or attr_off)

	i, j = 4, 0

	j = add_text(table, i, j, "P A S T ", (min >= 5 and min < 35) and attr_on or attr_off)
	j = add_text(table, i, j, "E R U ", attr_off)
	j = add_text(table, i, j, "N I N E ", hour == 9 and attr_on or attr_off)

	i, j = 5, 0

	j = add_text(table, i, j, "O N E ", hour == 1 and attr_on or attr_off)
	j = add_text(table, i, j, "S I X ", hour == 6 and attr_on or attr_off)
	j = add_text(table, i, j, "T H R E E ", hour == 3 and attr_on or attr_off)

	i, j = 6, 0

	j = add_text(table, i, j, "F O U R ", hour == 4 and attr_on or attr_off)
	j = add_text(table, i, j, "F I V E ", hour == 5 and attr_on or attr_off)
	j = add_text(table, i, j, "T W O ", hour == 2 and attr_on or attr_off)

	i, j = 7, 0

	j = add_text(table, i, j, "E I G H T ", hour == 8 and attr_on or attr_off)
	j = add_text(table, i, j, "E L E V E N ", hour == 11 and attr_on or attr_off)

	i, j = 8, 0

	j = add_text(table, i, j, "S E V E N ", hour == 7 and attr_on or attr_off)
	j = add_text(table, i, j, "T W E L V E ", hour == 12 and attr_on or attr_off)

	i, j = 9, 0

	j = add_text(table, i, j, "T E N ", hour == 10 and attr_on or attr_off)
	j = add_text(table, i, j, "S E ", attr_off)
	j = add_text(table, i, j, "O C L O C K ", (min < 5) and attr_on or attr_off)

	return table
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Build text table
	local text_table = build_text_table()

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	cairo_select_font_face(cr, clock_font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, clock_fontsize)

	-- Calculate text/font extents
	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, "M", t_extents)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	-- Calculate text position
	local col_width = t_extents.x_advance
	local row_height = (f_extents.height/2 - f_extents.descent)*2

	local x_init = (conky_window.width - 21*col_width)/2
	local y_init = (conky_window.height - 9*row_spacing - row_height)/2 + row_height

	-- Draw text
	for id, pt in pairs(text_table) do
		local x = x_init + (pt.col)*col_width
		local y = y_init + (pt.row)*row_spacing
	
		cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))
		cairo_move_to(cr, x, y)
		cairo_show_text(cr, pt.text)
		cairo_stroke(cr)
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
