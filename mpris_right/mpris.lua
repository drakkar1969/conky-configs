---------------------------------------
-- Variables
---------------------------------------
player_name="Lollypop"
image_size=80
frame_padding=1
frame_color=0x383c4a
frame_alpha=0.7
text_font="Ubuntu"
text_size_title=24
text_size_artist=18
text_size_pos=13
text_color_title=0x383c4a
text_color_artist=0x21232b
text_color_pos=0x4d5366
x_title=image_size+2*frame_padding+20
y_title=23
x_artist=x_title
y_artist=y_title+28
x_pos=x_title
y_pos=y_title+53

---------------------------------------
-- LUA FUNCTIONS
---------------------------------------
require 'cairo'
require 'imlib2'

---------------------------------------
-- Function rgb_to_r_g_b
---------------------------------------
function rgb_to_r_g_b(colour,alpha)
	return ((colour/0x10000)%0x100)/255.,((colour/0x100)%0x100)/255.,(colour%0x100)/255.,alpha
end

---------------------------------------
-- Function draw_frame
---------------------------------------
function draw_frame(cr)
	cairo_rectangle(cr, conky_window.width-(2*frame_padding+image_size), 0, image_size+2*frame_padding, image_size+2*frame_padding)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(frame_color,frame_alpha))
	cairo_fill(cr)
end

---------------------------------------
-- Function draw_imlib2_image
---------------------------------------
function draw_imlib2_image(cr, file)
	local image = imlib_load_image(file)
	if image==nil then return end

	draw_frame(cr)

	imlib_context_set_image(image)

	local width = imlib_image_get_width()
	local height = imlib_image_get_height()

	local scaled = imlib_create_cropped_scaled_image (0, 0, width, height, image_size, image_size)

	imlib_free_image()

	imlib_context_set_image(scaled)
	imlib_render_image_on_drawable(conky_window.width-(frame_padding+image_size), frame_padding)
	imlib_free_image()
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr, x, y, text, f_size, color)
	local extents=cairo_text_extents_t:create()
	cairo_select_font_face (cr, text_font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, f_size)
	cairo_set_source_rgba (cr, rgb_to_r_g_b(color, 1))
	cairo_text_extents(cr, text, extents)
	cairo_move_to (cr, conky_window.width-x-extents.width, y)
	cairo_show_text (cr, text)
	cairo_stroke (cr)
end

---------------------------------------
-- Function conky_albumart
---------------------------------------
function conky_albumart()
	if conky_window==nil then return end

	local metadata = conky_parse(string.format("${exec 'playerctl metadata --player=%s 2>/dev/null'}", player_name))

	if metadata==nil then return end

	local meta_title = conky_parse(string.format("${exec 'playerctl metadata --player=%s --format \"{{ uc(title) }}\"'}", player_name))
	local meta_artist = conky_parse(string.format("${exec 'playerctl metadata --player=%s --format \"{{ uc(artist) }}\"'}", player_name))
	local meta_pos = conky_parse(string.format("${exec 'playerctl metadata --player=%s --format \"{{ uc(status) }}: {{ duration(position) }} | {{ duration(mpris:length) }}\"'}", player_name))

	local meta_art = conky_parse(string.format("${exec 'playerctl metadata --player=Lollypop --format \"{{ mpris:artUrl }}\"'}", player_name))
	meta_art = meta_art:gsub("file:%/%/","")

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	draw_imlib2_image(cr, meta_art)

	draw_text(cr, x_title, y_title, meta_title, text_size_title, text_color_title)
	draw_text(cr, x_artist, y_artist, meta_artist, text_size_artist, text_color_artist)
	draw_text(cr, x_pos, y_pos, meta_pos, text_size_pos, text_color_pos)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
