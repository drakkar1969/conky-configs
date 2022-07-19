------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Player name
player_name = "Lollypop"

-- Alignment
align_right = false

-- Light/dark colors
dark_colors = true

-- Font/color variables
main_font = "Ubuntu"
main_color = dark_colors and 0x3d3846 or 0xdeddda
hilight_color = dark_colors and 0x241f31 or 0xc0bfbc

-- Element spacing
gaps = { x = 14, y = 14 }

-- Song cover art
cover_art = {
	image = {
		size = 70
	},
	frame = {
		width = 0,
		color = main_color,
		alpha = 1
	},
}

-- Tags table
tags = {
	-- "Now Playing" header
	header = {
		x = 1,
		y = 20,
		text = "NOW PLAYING",
		font = main_font,
		font_size = 15,
		bold = false,
		italic = false,
		color = main_color,
		alpha = 0.5
	},	
	-- Song title
	title = {
		text = "UNKNOWN TRACK",
		font = main_font,
		font_size = 23,
		bold = true,
		italic = false,
		color = main_color,
		alpha = 1,
	},
	-- Song artist
	artist = {
		text = "UNKNOWN ARTIST",
		font = main_font,
		font_size = 14,
		bold = false,
		italic = false,
		color = hilight_color,
		alpha = 1,
	},
	-- Track position
	position = {
		text = "0:00",
		font = main_font,
		font_size = 12,
		bold = true,
		italic = false,
		color = hilight_color,
		alpha = 1,
	}
}

-- Vertical line between cover and tags
divider = {
	width = 1,
	color = main_color,
	alpha = 0.15
}

-- Status icon (playing, paused, stopped)
status_icon = {
	size = 16,
	color = main_color,
	alpha = dark_colors and 0.75 or 0.9,
	play_icon = string.gsub(conky_config, 'mpris.conf', 'icons/play.svg'),
	pause_icon = string.gsub(conky_config, 'mpris.conf', 'icons/pause.svg'),
	stop_icon = string.gsub(conky_config, 'mpris.conf', 'icons/stop.svg')
}

-- Progress bar
progress_bar = {
	width = 220,
	height = 8,
	color_bg = main_color,
	color_fg = main_color,
	alpha_bg = dark_colors and 0.15 or 0.2,
	alpha_fg = dark_colors and 0.7 or 0.9
}

------------------------------------------------------------------------------
-- VARIABLE INITIALIZATION
------------------------------------------------------------------------------
-- Calculate cover image/frame position and dimensions
cover_art.frame.x = 10
cover_art.frame.y = tags.header.y + gaps.y
cover_art.frame.size = cover_art.image.size + 2*cover_art.frame.width
cover_art.image.x = cover_art.frame.x + cover_art.frame.width
cover_art.image.y = cover_art.frame.y + cover_art.frame.width

-- Calculate vertical line position and dimensions
divider.xs = cover_art.frame.x + cover_art.frame.size + gaps.x + divider.width/2
divider.ys = cover_art.frame.y
divider.xr = 0
divider.yr = cover_art.frame.size

-- Calculate status icon/progress bar position
temp_height = math.max(status_icon.size, progress_bar.height)

status_icon.x = cover_art.frame.x
status_icon.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - status_icon.size)/2

progress_bar.x = status_icon.x + status_icon.size + gaps.x
progress_bar.y = cover_art.frame.y + cover_art.frame.size + gaps.y + temp_height/2

-- Calculate tags position (y coordinate calculated in main func)
tags.title.x = cover_art.frame.x + cover_art.frame.size + divider.width + 2*gaps.x
tags.artist.x = cover_art.frame.x + cover_art.frame.size + divider.width + 2*gaps.x
tags.position.x = progress_bar.x + progress_bar.width + 1.3*gaps.x

------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'imlib2'
require 'rsvg'

------------------------------------------------------------------------------
-- AUXILIARY FUNCTIONS
------------------------------------------------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
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
-- Function draw_cover
---------------------------------------
function draw_cover(cr, pt)
	-- Draw frame
	local frame_x = (align_right and (conky_window.width - (pt.frame.x + pt.frame.size)) or pt.frame.x)

	cairo_rectangle(cr, frame_x, pt.frame.y, pt.frame.size, pt.frame.size)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.frame.color, pt.frame.alpha))
	cairo_fill(cr)

	-- Draw cover
	if (pt.file == nil or pt.file == "") then return end

	local image = imlib_load_image(pt.file)
	if image == nil then return end

	imlib_context_set_image(image)

	local image_x = (align_right and (conky_window.width - (pt.image.x + pt.image.size)) or pt.image.x)

	local scaled = imlib_create_cropped_scaled_image(0, 0, imlib_image_get_width(), imlib_image_get_height(), pt.image.size, pt.image.size)

	imlib_free_image()

	imlib_context_set_image(scaled)

	imlib_render_image_on_drawable(image_x, pt.image.y)

	imlib_free_image()
end

---------------------------------------
-- Function draw_rel_line
---------------------------------------
function draw_rel_line(cr, pt)
	local line_xs = (align_right and (conky_window.width - pt.xs) or pt.xs)

	cairo_move_to(cr, line_xs, pt.ys)
	cairo_rel_line_to(cr, pt.xr, pt.yr)

	cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
	cairo_set_line_width(cr, pt.width)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr, pt)
	local slant = (pt.italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL)
	local weight = (pt.bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)

	cairo_select_font_face(cr, pt.font, slant, weight)
	cairo_set_font_size(cr, pt.font_size)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))

	local text_x = pt.x

	if align_right then
		local extents = cairo_text_extents_t:create()
		tolua.takeownership(extents)
		cairo_text_extents(cr, pt.text, extents)
		text_x = conky_window.width - pt.x - extents.width - extents.x_bearing
	end

	cairo_move_to(cr, text_x, pt.y)
	cairo_show_text(cr, pt.text)
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_svg_icon
---------------------------------------
function draw_svg_icon(cr, pt)
	cairo_save(cr)

	-- Load SVG image from file
	local handle = rsvg_create_handle_from_file(pt.file)

	-- Get SVG image dimensions
	local svgprop = RsvgDimensionData:create()
	rsvg_handle_get_dimensions(handle, svgprop)

	local w, h, em, ex = svgprop:get()

	-- Position and size SVG image
	local icon_x = (align_right and (conky_window.width - (pt.x + pt.size)) or pt.x)

	cairo_translate(cr, icon_x, pt.y)
	cairo_scale(cr, pt.size/w, pt.size/h)

	-- Render SVG image on temporary canvas
	cairo_push_group(cr)
	rsvg_handle_render_cairo(handle, cr)

	-- Re-color and draw SVG image
	local pattern = cairo_pop_group(cr)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))

	cairo_mask(cr, pattern)

	cairo_pattern_destroy(pattern)

	rsvg_destroy_handle(handle)

	cairo_restore(cr)
end

---------------------------------------
-- Function draw_bar
---------------------------------------
function draw_bar(cr, pt)
	local bar_x = (align_right and (conky_window.width - (pt.x + pt.width)) or pt.x)

	cairo_move_to(cr, bar_x, pt.y)
	cairo_rel_line_to(cr, pt.width, 0)

	cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
	cairo_set_line_width(cr, pt.height)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color_bg, pt.alpha_bg))
	cairo_stroke(cr)

	cairo_move_to(cr, bar_x, pt.y)
	cairo_rel_line_to(cr, pt.width*pt.pct, 0)

	cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
	cairo_set_line_width(cr, pt.height)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color_fg, pt.alpha_fg))
	cairo_stroke(cr)
end

------------------------------------------------------------------------------
-- PARSE METADATA
------------------------------------------------------------------------------
function parse_metadata()
	-- Metadata format
	local meta_format = [[
	{{ mpris:artUrl }}
	{{ uc(title) }}
	{{ uc(artist) }}
	{{ uc(status) }}
	{{ position }}
	{{ mpris:length }}
	{{ duration(position) }}
	]]

	local parse_mask = [[
	file://(.-)
	(.-)
	(.-)
	(.-)
	(.-)
	(.-)
	(.-)
	]]

	-- Read metadata
	local metadata = {}

	local handle = io.popen(string.format("playerctl metadata --player=%s --format='%s' 2>/dev/null", player_name, meta_format))
	local meta_text = handle:read("*a")
	handle:close()

	if (meta_text == nil or meta_text == "") then return metadata end

	-- Extract metadata tags
	local s, f
	s, f, metadata.art, metadata.title, metadata.artist, metadata.status, metadata.pos, metadata.len, metadata.time = meta_text:find(parse_mask)

	-- Fix artist (remove album artist)
	if metadata.artist ~= "" then
		artist_list = {}
		separator = ", "

		for match in (metadata.artist..separator):gmatch("(.-)"..separator) do
			artist_list[#artist_list+1] = match
		end

		metadata.artist = artist_list[1]
	end

	return metadata
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Parse metadata
	local metadata = parse_metadata()

	if metadata.len ~= nil then
		local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

		local cr = cairo_create(cs)

		-- Calculate tags y coordinate
		local title_height = get_font_height(cr, tags.title.font, tags.title.font_size)
		local artist_height = get_font_height(cr, tags.artist.font, tags.artist.font_size)
		local position_height = get_font_height(cr, tags.position.font, tags.position.font_size)
		local tag_spacing = (cover_art.frame.size - title_height - artist_height)/3
		
		tags.title.y = cover_art.frame.y + title_height + tag_spacing
		tags.artist.y = tags.title.y + artist_height + tag_spacing
		tags.position.y = progress_bar.y + position_height/2

		-- Draw header
		draw_text(cr, tags.header)

		-- Draw cover with frame
		cover_art.file = metadata.art

		draw_cover(cr, cover_art)

		-- Draw vertical line
		draw_rel_line(cr, divider)

		-- Draw status icon
		status_icon.file = ((metadata.status == "PAUSED") and status_icon.pause_icon or ((metadata.status == "PLAYING") and status_icon.play_icon or status_icon.stop_icon))

		draw_svg_icon(cr, status_icon)

		-- Draw progressbar
		if (metadata.pos == nil or metadata.len == nil or metadata.len == 0) then
			progress_bar.pct = 0
		else
			progress_bar.pct = tonumber(metadata.pos)/tonumber(metadata.len)
		end

		draw_bar(cr, progress_bar)

		-- Draw tags
		tags.title.text = metadata.title
		tags.artist.text = metadata.artist

		draw_text(cr, tags.title)
		draw_text(cr, tags.artist)

		-- Draw position text
		tags.position.text = metadata.time

		draw_text(cr, tags.position)

		cairo_destroy(cr)
		cairo_surface_destroy(cs)
	end
end
