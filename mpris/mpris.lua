---------------------------------------
-- Variables
---------------------------------------
player_name="Lollypop"

align_r=false

cover_size=60
frame_padding=1
frame_color=0x383c4a
frame_alpha=1

tag_font="Ubuntu"
tag_x=cover_size+2*frame_padding+20
tag_y=0

---------------------------------------
-- Tag table
---------------------------------------
tags_table = {
	title = {
		tag="title",
		font=tag_font,
		font_size=22,
		color=0x383c4a,
		alpha=1,
		x=tag_x, y=tag_y+25
	},
	artist = {
		tag="artist",
		font=tag_font,
		font_size=16,
		color=0x21232b,
		alpha=1,
		x=tag_x, y=tag_y+53
	},
	pos = {
		tag="status",
		font=tag_font,
		font_size=13,
		color=0x383c4a,
		alpha=0.7,
		x=0, y=tag_y+83
	},
	cover = {
		tag="",
		x=0,y=0,
		size=cover_size,
		frame = {
			pad=frame_padding,
			color=frame_color,
			alpha=frame_alpha
		}
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
function draw_frame(cr,pt)
	if align_r then
		cairo_rectangle(cr, conky_window.width-(pt.size+2*pt.frame.pad), 0, pt.size+2*pt.frame.pad,pt.size+2*pt.frame.pad)
	else
		cairo_rectangle(cr,0,0,pt.size+2*pt.frame.pad,pt.size+2*pt.frame.pad)
	end

	cairo_set_source_rgba(cr,rgb_to_r_g_b(pt.frame.color,pt.frame.alpha))
	cairo_fill(cr)
end

---------------------------------------
-- Function draw_imlib2_image
---------------------------------------
function draw_imlib2_image(cr,pt)
	local image=imlib_load_image(pt.tag)
	if image == nil then return end

	draw_frame(cr,pt)

	imlib_context_set_image(image)

	local scaled=imlib_create_cropped_scaled_image(0,0,imlib_image_get_width(),imlib_image_get_height(),pt.size,pt.size)

	imlib_free_image()

	imlib_context_set_image(scaled)

	if align_r then
		imlib_render_image_on_drawable(conky_window.width-(pt.size+pt.frame.pad),pt.frame.pad)
	else
		imlib_render_image_on_drawable(pt.frame.pad,pt.frame.pad)
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
		cairo_text_extents(cr,pt.tag,extents)
		cairo_move_to(cr,conky_window.width-pt.x-extents.width,pt.y)
	else
		cairo_move_to(cr,pt.x,pt.y)
	end

	cairo_show_text(cr,pt.tag)
	cairo_stroke(cr)
end

---------------------------------------
-- Function conky_set_align
---------------------------------------
function conky_set_align(align)
	if align == 'right' then
		align_r=true
	end
end

---------------------------------------
-- Function conky_albumart
---------------------------------------
function conky_albumart()
	if conky_window==nil then return end

	-- Get metadata
	local metadata=conky_parse(string.format("${exec 'playerctl metadata --player=%s --format=\"parse:title{{ uc(title) }}\nparse:artist{{ uc(artist) }}\nparse:pos{{ uc(status) }}: {{ duration(position) }} | {{ duration(mpris:length) }}\nparse:cover{{ mpris:artUrl }}\n\" 2>/dev/null'}", player_name))

	if (metadata == nil or metadata == "") then return end

	local s,f

	s,f,tags_table.title.tag=metadata:find("parse:title(.-)\n")
	s,f,tags_table.artist.tag=metadata:find("parse:artist(.-)\n")
	s,f,tags_table.pos.tag=metadata:find("parse:pos(.-)\n")
	s,f,tags_table.cover.tag=metadata:find("parse:coverfile://(.-)\n")

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	-- Draw cover with frame
	draw_imlib2_image(cr,tags_table.cover)

	-- Draw text
	draw_text(cr,tags_table.title)
	draw_text(cr,tags_table.artist)
	draw_text(cr,tags_table.pos)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
