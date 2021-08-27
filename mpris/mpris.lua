---------------------------------------
-- Variables
---------------------------------------
player_name="Lollypop"

align_r=false

image_size=80
frame_padding=1
frame_color=0x383c4a
frame_alpha=1

text_font="Ubuntu"
text_x=image_size+2*frame_padding+20
text_y=23

---------------------------------------
-- Text table
---------------------------------------
text_table = {
	title = {
		text="title",
		font=text_font,
		font_size=22,
		color=0x383c4a,
		alpha=1,
		x=text_x, y=text_y
	},
	artist = {
		text="artist",
		font=text_font,
		font_size=16,
		color=0x21232b,
		alpha=1,
		x=text_x, y=text_y+28
	},
	pos = {
		text="status",
		font=text_font,
		font_size=13,
		color=0x383c4a,
		alpha=0.7,
		x=text_x, y=text_y+53
	}
}

---------------------------------------
-- LUA FUNCTIONS
---------------------------------------
require 'cairo'
require 'imlib2'

---------------------------------------
-- Function rgb_to_r_g_b
---------------------------------------
function rgb_to_r_g_b(color,alpha)
	return ((color/0x10000)%0x100)/255.,((color/0x100)%0x100)/255.,(color%0x100)/255.,alpha
end

---------------------------------------
-- Function draw_frame
---------------------------------------
function draw_frame(cr)
	if align_r then
		cairo_rectangle(cr, conky_window.width-(image_size+2*frame_padding), 0, image_size+2*frame_padding,image_size+2*frame_padding)
	else
		cairo_rectangle(cr,0,0,image_size+2*frame_padding,image_size+2*frame_padding)
	end
	cairo_set_source_rgba(cr,rgb_to_r_g_b(frame_color,frame_alpha))
	cairo_fill(cr)
end

---------------------------------------
-- Function draw_imlib2_image
---------------------------------------
function draw_imlib2_image(cr,file)
	local image=imlib_load_image(file)
	if image == nil then return end

	draw_frame(cr)

	imlib_context_set_image(image)

	local width=imlib_image_get_width()
	local height=imlib_image_get_height()

	local scaled=imlib_create_cropped_scaled_image(0,0,width,height,image_size,image_size)

	imlib_free_image()

	imlib_context_set_image(scaled)
	if align_r then
		imlib_render_image_on_drawable(conky_window.width-(image_size+frame_padding),frame_padding)
	else
		imlib_render_image_on_drawable(frame_padding,frame_padding)
	end
	imlib_free_image()
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr,pt)
	cairo_select_font_face(cr,pt.font,CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr,pt.font_size)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(pt.color,pt.alpha))
	if align_r then
		local extents=cairo_text_extents_t:create()
		cairo_text_extents(cr,pt.text,extents)
		cairo_move_to(cr,conky_window.width-pt.x-extents.width,pt.y)
	else
		cairo_move_to(cr,pt.x,pt.y)
	end
	cairo_show_text(cr,pt.text)
	cairo_stroke(cr)
end

---------------------------------------
-- Function conky_albumart
---------------------------------------
function conky_albumart(align)
	if conky_window==nil then return end

	if align == 'right' then
		align_r=true
	end

	-- Get metadata
	local metadata=conky_parse(string.format("${exec 'playerctl metadata --player=%s --format=\"xesam:title{{ uc(title) }}\nxesam:artist{{ uc(artist) }}\nxesam:pos{{ uc(status) }}: {{ duration(position) }} | {{ duration(mpris:length) }}\nxesam:albumArt{{ mpris:artUrl }}\n\" 2>/dev/null'}", player_name))

	if (metadata == nil or metadata == "") then return end

	local s,f,meta_art

	s,f,text_table.title.text=metadata:find("xesam:title(.-)\n")
	s,f,text_table.artist.text=metadata:find("xesam:artist(.-)\n")
	s,f,text_table.pos.text=metadata:find("xesam:pos(.-)\n")
	s,f,meta_art=metadata:find("xesam:albumArtfile://%s*(.-)\n")

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	-- Draw cover with frame
	draw_imlib2_image(cr,meta_art)

	-- Draw text
	draw_text(cr,text_table.title)
	draw_text(cr,text_table.artist)
	draw_text(cr,text_table.pos)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
