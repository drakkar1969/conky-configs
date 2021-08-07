---------------------------------------
-- Image variables
---------------------------------------
image_size=90
frame_padding=1
frame_color=0x383c4a
frame_alpha=0.7

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
function draw_frame()
	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	cairo_rectangle(cr, 0, 0, image_size+2*frame_padding, image_size+2*frame_padding)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(frame_color,frame_alpha))
	cairo_fill(cr)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end

---------------------------------------
-- Function draw_imlib2_image
---------------------------------------
function draw_imlib2_image(file)
	draw_frame()

	local image = imlib_load_image(file)
	imlib_context_set_image(image)

	local width = imlib_image_get_width()
	local height = imlib_image_get_height()

	local buffer = imlib_create_image(image_size, image_size)
	imlib_context_set_image(buffer)

	imlib_blend_image_onto_image(image, 0, 0, 0, width, height, 0, 0, image_size, image_size)
	imlib_context_set_image(image)
	imlib_free_image()

	imlib_context_set_image(buffer)
	imlib_render_image_on_drawable(frame_padding, frame_padding)
	imlib_free_image()
end

---------------------------------------
-- Function conky_albumart
---------------------------------------
function conky_albumart()
	if conky_window==nil then return end

	image_path = conky_parse("${exec 'playerctl metadata --player=Lollypop --format \"{{ mpris:artUrl }}\" 2>/dev/null'}")

	if image_path==nil then return end
	if image_path=="" then return end

	image_path = image_path:gsub("file:%/%/","")

	draw_imlib2_image(image_path)
end
