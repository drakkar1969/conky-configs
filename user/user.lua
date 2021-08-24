---------------------------------------
-- Image variables
---------------------------------------
image_size=80
image_x=0
image_y=0
image_alpha=1
image_path=string.format('%s%s',conky_config,'.png')

---------------------------------------
-- LUA FUNCTIONS
---------------------------------------
require 'cairo'

---------------------------------------
-- Function draw_round_image
---------------------------------------
function draw_round_image(cr, file)
	cairo_save(cr)

	local cs=cairo_image_surface_create_from_png(file)

	local width=cairo_image_surface_get_width(cs)
	local height=cairo_image_surface_get_height(cs)
	local w_ratio=image_size/width
	local h_ratio=image_size/height
	local radius=math.min(width, height)/2

	cairo_scale(cr,w_ratio,h_ratio)
	cairo_translate(cr,image_x/w_ratio,image_y/h_ratio)
	cairo_arc(cr,width/2,height/2,radius,0,2*math.pi)
	cairo_clip(cr)

	cairo_set_source_surface(cr,cs,0,0)
	cairo_paint_with_alpha(cr,image_alpha)

	cairo_restore(cr)
	cairo_surface_destroy(cs)
end

---------------------------------------
-- Function conky_rings
---------------------------------------
function conky_user()
	if conky_window==nil then return end

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	draw_round_image(cr,image_path)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
