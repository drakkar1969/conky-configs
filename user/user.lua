------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Alignment
align_right = false

-- Light/dark colors
dark_colors = true

-- User picture
avatar = {
	x = 0,
	y = 0,
	size = 70,
	margin = 20
}

-- User name
username = {
	font = 'Ubuntu',
	font_size = 24,
	bold = true,
	italic = false,
	color = dark_colors and 0x3d3846 or 0xdeddda,
	alpha = 1
}

-- GNOME version
gnomever = {
	font = 'Ubuntu',
	font_size = 14,
	bold = false,
	italic = false,
	color = dark_colors and 0x3d3846 or 0xdeddda,
	alpha = 1
}

------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'imlib2'

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

function get_font_height(cr, font, font_size)
	cairo_save(cr)

	cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font_size)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	cairo_restore(cr)

	return (f_extents.height/2 - f_extents.descent)*2
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
	cairo_set_font_size(cr, pt.font_size)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))

	-- Calculate text and font extents
	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, pt.text, t_extents)

	-- Justify text
	local text_x = (align_right and (conky_window.width - pt.x - t_extents.width - t_extents.x_bearing) or pt.x)

	-- Draw text
	cairo_move_to(cr, text_x, pt.y)
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

	-- Get avatar, user name and GNOME version
	local user_name = conky_parse('${exec "id -un"}')
	local user_icon = "/var/lib/AccountsService/icons/"..user_name
	local gnome_version = conky_parse('${exec "gnome-shell --version"}')

	username.text = user_name
	gnomever.text = gnome_version

	-- Convert avatar to PNG format
	avatar.outfile = string.gsub(conky_config, 'user.conf', 'user.png')

	convert_to_png(user_icon, avatar.outfile)

	-- Draw avatar
	draw_round_image(cr, avatar)

	-- Calculate text coordinates
	local user_name_height = get_font_height(cr, username.font, username.font_size)
	local gnome_version_height = get_font_height(cr, gnomever.font, gnomever.font_size)
	local text_gap = (avatar.size - user_name_height - gnome_version_height)/3

	username.x = avatar.x + avatar.size + avatar.margin
	username.y = avatar.y + user_name_height + text_gap

	gnomever.x = username.x
	gnomever.y = username.y + gnome_version_height + text_gap

	-- Draw text
	draw_text(cr, username)
	draw_text(cr, gnomever)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
