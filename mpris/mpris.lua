------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Light/dark colors
dark_colors = true

-- Progress bar dot (false = full progress bar)
progress_dot = false
progress_square = false

-- Show cover art
show_cover_art = true

-- Assets
play_icon = string.gsub(conky_config, 'mpris.conf', 'icons/play.svg')
pause_icon = string.gsub(conky_config, 'mpris.conf', 'icons/pause.svg')
stop_icon = string.gsub(conky_config, 'mpris.conf', 'icons/stop.svg')
audio_icon = string.gsub(conky_config, 'mpris.conf', 'icons/audio.svg')

-- Font/color variables
main_font = "Ubuntu"
main_color = dark_colors and 0x3d3846 or 0xdeddda
hilight_color = dark_colors and 0x241f31 or 0xc0bfbc

-- Element spacing
gaps = { text = 14, progress = 10, y = 14 }

-- Song cover art
cover_art = {
	image = {
		size = 70
	},
	frame = {
		x = 10,
		width = 0,
		color = main_color,
		alpha = 0.1
	},
	icon = {
		size = 32,
		color = main_color,
		alpha = 0.9,
		file = audio_icon
	}		
}

-- Tags table
tags = {
	-- "Now Playing" header
	header = {
		x = 1,
		y = 20,
		text = "NOW PLAYING",
		font = main_font,
		font_size = 13,
		bold = true,
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
		font_size = 15,
		bold = false,
		italic = false,
		color = hilight_color,
		alpha = 1,
	},
	-- Track position
	time = {
		text = "0:00",
		font = main_font,
		font_size = 13,
		bold = true,
		italic = false,
		color = main_color,
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
	alpha = dark_colors and 0.85 or 0.9,
	file = ""
}

-- Progress bar
progress_bar = {
	width = 200,
	height = 8,
	color_bg = main_color,
	color_fg = main_color,
	alpha_bg = dark_colors and 0.15 or 0.2,
	alpha_fg = dark_colors and 0.8 or 0.9
}

------------------------------------------------------------------------------
-- VARIABLE INITIALIZATION
------------------------------------------------------------------------------
-- Calculate cover image/frame position and dimensions
cover_art.frame.y = tags.header.y + gaps.y
cover_art.frame.size = cover_art.image.size + 2*cover_art.frame.width
cover_art.image.x = cover_art.frame.x + cover_art.frame.width
cover_art.image.y = cover_art.frame.y + cover_art.frame.width

cover_art.icon.x = cover_art.image.x + (cover_art.image.size - cover_art.icon.size)/2
cover_art.icon.y = cover_art.image.y + (cover_art.image.size - cover_art.icon.size)/2

-- Calculate vertical line position and dimensions
divider.xs = cover_art.frame.x + cover_art.frame.size + gaps.text + divider.width/2
divider.ys = cover_art.frame.y
divider.xr = 0
divider.yr = cover_art.frame.size

-- Calculate status icon position
temp_height = math.max(status_icon.size, progress_bar.height)

status_icon.x = cover_art.frame.x
status_icon.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - status_icon.size)/2

-- Calculate progress bar position (x coordinate calculated in main func)
progress_bar.y = cover_art.frame.y + cover_art.frame.size + gaps.y + temp_height/2

-- Calculate tags position (y coordinate calculated in main func)
tags.title.x = cover_art.frame.x + cover_art.frame.size + divider.width + 2*gaps.text
tags.artist.x = cover_art.frame.x + cover_art.frame.size + divider.width + 2*gaps.text

-- Note: pos/len tags x,y coordinates calculated in main func

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

function get_text_width(cr, font, font_size, text)
	cairo_save(cr)

	cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font_size)

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local retval = (t_extents.width - t_extents.x_bearing)

	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)

	cairo_restore(cr)

	return retval
end

function get_font_height(cr, font, font_size)
	cairo_save(cr)

	cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font_size)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	local retval = (f_extents.height/2 - f_extents.descent)*2

	tolua.releaseownership(f_extents)
	cairo_font_extents_t:destroy(f_extents)

	cairo_restore(cr)

	return retval
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_cover
---------------------------------------
function draw_cover(cr, pt)
	-- Draw frame
	cairo_rectangle(cr, pt.frame.x, pt.frame.y, pt.frame.size, pt.frame.size)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.frame.color, pt.frame.alpha))
	cairo_fill(cr)

	-- Draw audio icon
	if (show_cover_art == false or pt.file == nil or pt.file == "") then
			draw_svg_icon(cr, pt.icon)
	-- Draw cover
	else
		local image = imlib_load_image(pt.file)
		if image == nil then
			draw_svg_icon(cr, pt.icon)
		else
			imlib_context_set_image(image)

			local scaled = imlib_create_cropped_scaled_image(0, 0, imlib_image_get_width(), imlib_image_get_height(), pt.image.size, pt.image.size)

			imlib_free_image()

			imlib_context_set_image(scaled)

			imlib_render_image_on_drawable(pt.image.x, pt.image.y)

			imlib_free_image()
		end
	end
end

---------------------------------------
-- Function draw_rel_line
---------------------------------------
function draw_rel_line(cr, pt)
	cairo_move_to(cr, pt.xs, pt.ys)
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

	cairo_move_to(cr, pt.x, pt.y)
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

	-- Position and size SVG image
	local svg_rect = RsvgRectangle:create()
	tolua.takeownership(svg_rect)

	svg_rect:set(pt.x, pt.y, pt.size, pt.size)

	-- Render SVG image on temporary canvas
	local err

	cairo_push_group(cr)
	rsvg_handle_render_document(handle, cr, svg_rect, err)

	-- Destroy objects
	tolua.releaseownership(svg_rect)
	RsvgRectangle:destroy(svg_rect)

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
	cairo_set_line_cap(cr, (progress_square == true and CAIRO_LINE_CAP_SQUARE or CAIRO_LINE_CAP_ROUND))
	cairo_set_line_width(cr, pt.height)

	-- Draw progress background
	cairo_move_to(cr, pt.x, pt.y)
	cairo_rel_line_to(cr, pt.width, 0)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color_bg, pt.alpha_bg))
	cairo_stroke(cr)

	-- Draw progress foreground
	if progress_dot then
		cairo_move_to(cr, pt.x + pt.width*pt.pct, pt.y)
		cairo_rel_line_to(cr, 0, 0)
	else
		cairo_move_to(cr, pt.x, pt.y)
		cairo_rel_line_to(cr, pt.width*pt.pct, 0)
	end
	
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color_fg, pt.alpha_fg))
	cairo_stroke(cr)
end

------------------------------------------------------------------------------
-- PARSE METADATA
------------------------------------------------------------------------------
function microsecs_to_string(microsecs)
	local secs = math.floor(microsecs/1000000)

	local mins = math.floor(secs/60)
	secs = math.floor(secs%60)

	local hrs = math.floor(mins/60)
	mins = math.floor(mins%60)

	local str = ""

	if hrs ~= 0 then
		str = string.format("%d:%02d:%02d", hrs, mins, secs)
	else
		str = string.format("%d:%02d", mins, secs)
	end

	return str
end

function parse_metadata()
	local lgi = require 'lgi'
	local playerctl = lgi.Playerctl

	local player = playerctl.Player()

	-- Initializa metadata table
	local metadata = { player_name = player.player_name }

	if metadata.player_name ~= nil then
		for i, variant in ipairs(player.metadata) do
			-- Get key name
			local key = variant[1]

			-- Simplify key name
			key = string.gsub(key, "xesam:", "")
			key = string.gsub(key, "mpris:", "")
	
			-- If value is a list, get first element as value
			if variant[2].type == "as" then
				for j, value in ipairs(variant[2]) do
					if j == 1 then metadata[key] = value end
				end
			-- Get value
			else
				metadata[key] = variant[2].value

				-- Get artUrl path
				if key == "artUrl" then
					metadata[key] = string.gsub(metadata[key], "file://", "")
				end
			end
		end

		metadata.status = string.upper(player.playback_status)
		metadata.position = player.position
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

	if metadata.player_name ~= nil and metadata.trackid ~= "/org/mpris/MediaPlayer2/TrackList/NoTrack" then
		local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

		local cr = cairo_create(cs)

		-- Draw header
		draw_text(cr, tags.header)

		-- Draw cover with frame
		cover_art.file = metadata.artUrl

		draw_cover(cr, cover_art)

		-- Draw vertical line
		draw_rel_line(cr, divider)

		-- Draw tags
		local title_height = get_font_height(cr, tags.title.font, tags.title.font_size)
		local artist_height = get_font_height(cr, tags.artist.font, tags.artist.font_size)

		local tag_spacing = (cover_art.frame.size - title_height - artist_height)/3

		tags.title.y = cover_art.frame.y + title_height + tag_spacing
		tags.artist.y = tags.title.y + artist_height + tag_spacing

		tags.title.text = string.upper(metadata.title)
		tags.artist.text = string.upper(metadata.artist)

		draw_text(cr, tags.title)
		draw_text(cr, tags.artist)

		-- Draw status icon
		status_icon.file = ((metadata.status == "PAUSED") and pause_icon or ((metadata.status == "PLAYING") and play_icon or stop_icon))

		draw_svg_icon(cr, status_icon)

		-- Draw progressbar
		local time_space = get_text_width(cr, tags.time.font, tags.time.font_size, "00:00")

		progress_bar.x = status_icon.x + status_icon.size + time_space + 2*gaps.progress + progress_bar.height/2

		if metadata.length == 0 then
			progress_bar.pct = 0
		else
			progress_bar.pct = tonumber(metadata.position)/tonumber(metadata.length)
		end

		draw_bar(cr, progress_bar)

		-- Draw pos text
		local time_width = 0
		local time_height = get_font_height(cr, tags.time.font, tags.time.font_size)
		
		tags.time.y = progress_bar.y + time_height/2

		tags.time.text = microsecs_to_string(metadata.position)

		time_width = get_text_width(cr, tags.time.font, tags.time.font_size, tags.time.text)

		tags.time.x = status_icon.x + status_icon.size + time_space/2 - time_width/2 + gaps.progress

		draw_text(cr, tags.time)

		-- Draw len text
		tags.time.text = microsecs_to_string(metadata.length)

		time_width = get_text_width(cr, tags.time.font, tags.time.font_size, tags.time.text)

		tags.time.x = progress_bar.x + progress_bar.width + time_space/2 - time_width/2 + gaps.progress + progress_bar.height

		draw_text(cr, tags.time)

		cairo_destroy(cr)
		cairo_surface_destroy(cs)
	end
end
