---------------------------------------
-- Variables
---------------------------------------

-- Player name
player_name="Lollypop"

-- Alignment
align_r=false

-- Gaps
gap_x=14
gap_y=14

-- Header
header_x=1
header_y=20

-- Cover
cover = {
	file="",
	size=60,
	padding=1,
	frame_color=0x383c4a,
	frame_alpha=1,
	x=0,
	y=header_y+gap_y
}

-- Tags
tag_font="Ubuntu"
tag_x=cover.size+2*cover.padding+2*gap_x
tag_y=header_y+gap_y

-- Lines
line_color=0x383c4a
line_alpha=0.25

-- Status icon
status_icon = {
	file="",
	size=11,
	alpha=0.7,
	x=0,
	y=cover.y+cover.size+2*cover.padding+gap_y
}

icon_play=string.gsub(conky_config,'mpris.conf','icons/play.png')
icon_pause=string.gsub(conky_config,'mpris.conf','icons/pause.png')

-- Bar
bar_w=200
bar_h=5
bar_color_bg=0x383c4a
bar_color_fg=0x383c4a
bar_alpha_bg=0.2
bar_alpha_fg=0.6

---------------------------------------
-- Text table
---------------------------------------
text_table = {
	header = {
		text="NOW PLAYING",
		font="Ubuntu",
		font_size=15,
		bold=false,
		italic=false,
		color=0x383c4a,
		alpha=0.55,
		x=header_x, y=header_y
	},
	title = {
		text="title",
		font=tag_font,
		font_size=24,
		bold=false,
		italic=false,
		color=0x383c4a,
		alpha=1,
		x=tag_x, y=tag_y+54
	},
	artist = {
		text="artist",
		font=tag_font,
		font_size=17,
		bold=false,
		italic=false,
		color=0x21232b,
		alpha=1,
		x=tag_x, y=tag_y+20
	},
}

---------------------------------------
-- Line table
---------------------------------------
line_table = {
	{
		color=line_color,
		alpha=line_alpha,
		w=2,
		xs=cover.size+2*cover.padding+gap_x, ys=header_y+gap_y,
		xe=cover.size+2*cover.padding+gap_x, ye=header_y+gap_y+cover.size+2*cover.padding
	}
}

---------------------------------------
-- Bar table
---------------------------------------
bar_table = {
	pos = {
		pct=0,
		x=status_icon.size+gap_x,
		y=status_icon.y+(status_icon.size-bar_h)/2,
		w=bar_w, h=bar_h,
		color_bg=bar_color_bg,
		alpha_bg=bar_alpha_bg,
		color_fg=bar_color_fg,
		alpha_fg=bar_alpha_fg
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
-- Function draw_text
---------------------------------------
function draw_text(cr,pt)
	local font_slant=(pt.italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL)
	local font_bold=(pt.bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)

	cairo_select_font_face(cr,pt.font,font_slant,font_bold)
	cairo_set_font_size(cr,pt.font_size)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(pt.color,pt.alpha))

	local text_x=pt.x

	if align_r then
		local extents=cairo_text_extents_t:create()
		cairo_text_extents(cr,pt.text,extents)
		text_x=conky_window.width-pt.x-extents.width
	end

	cairo_move_to(cr,text_x,pt.y)
	cairo_show_text(cr,pt.text)
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_cover
---------------------------------------
function draw_cover(cr,pt)
	-- Draw frame
	local frame_size=pt.size+2*pt.padding
	local frame_x=(align_r and (conky_window.width-(pt.x+frame_size)) or pt.x)

	cairo_rectangle(cr,frame_x,pt.y,frame_size,frame_size)

	cairo_set_source_rgba(cr,rgb_to_r_g_b(pt.frame_color,pt.frame_alpha))
	cairo_fill(cr)

	-- Draw cover
	local image=imlib_load_image(pt.file)
	if image == nil then return end

	imlib_context_set_image(image)

	local scaled=imlib_create_cropped_scaled_image(0,0,imlib_image_get_width(),imlib_image_get_height(),pt.size,pt.size)

	imlib_free_image()

	imlib_context_set_image(scaled)

	local image_x=(align_r and (conky_window.width-(pt.x+pt.padding+pt.size)) or (pt.x+pt.padding))

	imlib_render_image_on_drawable(image_x,pt.y+pt.padding)

	imlib_free_image()
end

---------------------------------------
-- Function draw_line
---------------------------------------
function draw_line(cr,pt)
	local line_xs=(align_r and (conky_window.width-pt.xs) or pt.xs)
	local line_xe=(align_r and (conky_window.width-pt.xe) or pt.xe)

	cairo_move_to(cr,line_xs,pt.ys)
	cairo_line_to(cr,line_xe,pt.ye)

	cairo_set_line_cap(cr,CAIRO_LINE_CAP_BUTT)
	cairo_set_line_width(cr,pt.w)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(pt.color,pt.alpha))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_icon
---------------------------------------
function draw_icon(cr,pt)
	cairo_save(cr)

	local cs=cairo_image_surface_create_from_png(pt.file)

	local icon_x=(align_r and (conky_window.width-(pt.x+pt.size)) or pt.x)

	cairo_set_source_surface(cr,cs,icon_x,pt.y)
	cairo_paint_with_alpha(cr,pt.alpha)

	cairo_restore(cr)
	cairo_surface_destroy(cs)
end

---------------------------------------
-- Function draw_bar
---------------------------------------
function draw_bar(cr,pt)
	local bar_x=(align_r and (conky_window.width-(pt.x+pt.w)) or pt.x)

	cairo_rectangle(cr,bar_x,pt.y,pt.w,pt.h)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(pt.color_bg,pt.alpha_bg))
	cairo_fill(cr)

	cairo_rectangle(cr,bar_x,pt.y,pt.w*pt.pct,pt.h)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(pt.color_fg,pt.alpha_fg))
	cairo_fill(cr)
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
	local meta_format=[[
	tag:cover{{ mpris:artUrl }}
	tag:title{{ uc(title) }}
	tag:artist{{ uc(artist) }}
	tag:status{{ uc(status) }}
	tag:pos{{ position }}
	tag:len{{ mpris:length }}
	]]

	local metadata=conky_parse(string.format("${exec 'playerctl metadata --player=%s --format=\"%s\" 2>/dev/null'}", player_name, meta_format))

	if (metadata == nil or metadata == "") then return end

	local s,f

	-- Get cover file
	s,f,cover.file=metadata:find("tag:coverfile://(.-)\n")

	-- Get tags
	s,f,text_table.title.text=metadata:find("tag:title(.-)\n")
	s,f,text_table.artist.text=metadata:find("tag:artist(.-)\n")

	-- Get status icon
	local status

	s,f,status=metadata:find("tag:status(.-)\n")

	status_icon.file=((status == "PAUSED") and icon_pause or icon_play)

	-- Get position/length
	local pos,len

	s,f,pos=metadata:find("tag:pos(.-)\n")
	s,f,len=metadata:find("tag:len(.-)\n")

	bar_table.pos.pct=tonumber(pos)/tonumber(len)

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	-- Draw header
	draw_text(cr,text_table.header)

	-- Draw cover with frame
	draw_cover(cr,cover)

	-- Draw tags
	draw_text(cr,text_table.title)
	draw_text(cr,text_table.artist)

	-- Draw lines
	for i in pairs(line_table) do
		draw_line(cr,line_table[i])
	end

	-- Draw status icon
	draw_icon(cr,status_icon)

	-- Draw progressbar
	draw_bar(cr,bar_table.pos)

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
