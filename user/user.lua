------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Alignment
align_right = false

-- Light/dark colors
dark_colors = false

-- User picture
avatar = {
	size = 70
}

-- User name
username = {
	font = 'Ubuntu',
	fontsize = 26,
	bold = false,
	italic = false,
	color = dark_colors and 0x3d3846 or 0xdeddda,
	alpha = 1,
	margin = 20
}

------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'imlib2'

------------------------------------------------------------------------------
-- VARIABLE INITIALIZATION
------------------------------------------------------------------------------
avatar.x = 0
avatar.y = 0
avatar.outfile = string.gsub(conky_config, 'user.conf', 'user.png')

username.x = avatar.x + avatar.size + username.margin
username.y = avatar.y + avatar.size/2

------------------------------------------------------------------------------
-- AUXILIARY FUNCTIONS
------------------------------------------------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

function convert_to_png(infile, outfile)
	local image = imlib_load_image(infile)
	if image == nil then return end

	imlib_context_set_image(image)

	imlib_image_set_format("png")

	imlib_save_image(outfile)

	imlib_free_image()
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_round_image
---------------------------------------
function draw_round_image(cr, im)
	cairo_save(cr)

	local cs = cairo_image_surface_create_from_png(im.outfile)

	local width = cairo_image_surface_get_width(cs)
	local height = cairo_image_surface_get_height(cs)
	local w_ratio = im.size/width
	local h_ratio = im.size/height
	local radius = math.min(width, height)/2

	local image_x = (align_right and (conky_window.width - (im.x + im.size)) or im.x)

	cairo_scale(cr, w_ratio, h_ratio)
	cairo_translate(cr, image_x/w_ratio, im.y/h_ratio)
	cairo_arc(cr, width/2, height/2, radius, 0, 2*math.pi)
	cairo_clip(cr)

	cairo_set_source_surface(cr, cs, 0, 0)
	cairo_paint(cr)

	cairo_restore(cr)
	cairo_surface_destroy(cs)
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr, pt)
	-- Set text font/color
	local slant = (pt.italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL)
	local weight = (pt.bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)

	cairo_select_font_face(cr, pt.font, slant, weight)
	cairo_set_font_size(cr, pt.fontsize)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))

	local text = conky_parse(pt.text)

	-- Calculate text and font extents
	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	-- Justify text
	local text_x = (align_right and (conky_window.width - pt.x - t_extents.width - t_extents.x_bearing) or pt.x)
	local text_y = pt.y + f_extents.height/2 - f_extents.descent

	-- Draw text
	cairo_move_to(cr, text_x, text_y)
	cairo_show_text(cr, text)
	cairo_stroke(cr)
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Get username and avatar
	local user_name = conky_parse('${exec "id -un"}')
	local user_icon = "/var/lib/AccountsService/icons/"..user_name

	convert_to_png(user_icon, avatar.outfile)

	username.text = user_name:upper()

	-- Draw username and avatar
	draw_round_image(cr, avatar)

	draw_text(cr, username)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
