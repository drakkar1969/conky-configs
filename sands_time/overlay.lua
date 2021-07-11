require 'cairo'

function draw_image(cr)
	local image = cairo_image_surface_create_from_png ("/home/drakkar/.config/conky/sands_time/overlay.png")

	cairo_set_source_surface (cr, image, 0, 260)
	cairo_paint (cr);

	cairo_surface_destroy (image);
end


function conky_start()
	if conky_window == nil then return end

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
	local cr=cairo_create(cs)

	draw_image(cr)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
