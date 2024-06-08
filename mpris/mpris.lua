------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Player name
player_name = "Lollypop"

-- Light/dark colors
dark_colors = true

-- Progress bar dot (false = full progress bar)
progress_dot = false
progress_square = false

-- Show cover art
show_cover_art = true

-- Show shuffle/loop icons
show_shuffle = true
show_loop = true

-- Assets
icon_play = string.gsub(conky_config, 'mpris.conf', 'icons/play.svg')
icon_pause = string.gsub(conky_config, 'mpris.conf', 'icons/pause.svg')
icon_stop = string.gsub(conky_config, 'mpris.conf', 'icons/stop.svg')
icon_audio = string.gsub(conky_config, 'mpris.conf', 'icons/audio.svg')
icon_shuffle = string.gsub(conky_config, 'mpris.conf', 'icons/shuffle.svg')
icon_loop = string.gsub(conky_config, 'mpris.conf', 'icons/loop.svg')

-- Font/color variables
main_font = "Ubuntu"
main_color = dark_colors and 0x3d3846 or 0xdeddda
hilight_color = dark_colors and 0x241f31 or 0xc0bfbc

-- Element spacing
gaps = { tags = 14, progress = 10, y = 14 }

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
		file = icon_audio
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
		text = "",
		font = main_font,
		font_size = 25,
		bold = false,
		italic = false,
		color = main_color,
		alpha = 1,
	},
	-- Song artist
	artist = {
		text = "",
		font = main_font,
		font_size = 15,
		bold = false,
		italic = false,
		color = hilight_color,
		alpha = 1,
	},
	-- Track position
	time = {
		text = "",
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

-- Icons table
icons = {
	status = {
		size = 16,
		color = main_color,
		alpha = dark_colors and 0.85 or 0.9,
		file = ""
	},
	shuffle = {
		size = 16,
		color = main_color,
		alpha = dark_col32ors and 0.85 or 0.9,
		file = icon_shuffle
	},
	loop = {
		size = 16,
		color = main_color,
		alpha = dark_colors and 0.85 or 0.9,
		file = icon_loop
	}
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
-- MOUSE VARIABLES (DO NOT MODIFY)
------------------------------------------------------------------------------
play_button_down = false

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
divider.xs = cover_art.frame.x + cover_art.frame.size + gaps.tags + divider.width/2
divider.ys = cover_art.frame.y
divider.xr = 0
divider.yr = cover_art.frame.size

-- Calculate icon positions (some x coordinates calculated in main function)
temp_height = math.max(icons.status.size, icons.shuffle.size, icons.loop.size, progress_bar.height)

icons.status.x = cover_art.frame.x
icons.status.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - icons.status.size)/2

icons.shuffle.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - icons.shuffle.size)/2

icons.loop.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - icons.loop.size)/2

-- Calculate progress bar position (x coordinate calculated in main func)
progress_bar.y = cover_art.frame.y + cover_art.frame.size + gaps.y + temp_height/2

-- Calculate tags position (y coordinate calculated in main func)
tags.title.x = cover_art.frame.x + cover_art.frame.size + divider.width + 2*gaps.tags
tags.artist.x = cover_art.frame.x + cover_art.frame.size + divider.width + 2*gaps.tags

-- Note: pos/len tags x,y coordinates calculated in main func

------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'
require 'cairo_imlib2_helper'
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
	if (show_cover_art == false or pt.image.file == nil or pt.image.file == "") then
		draw_svg_icon(cr, pt.icon)
	-- Draw cover
	else
		cairo_place_image(pt.image.file, cr, pt.image.x, pt.image.y, pt.image.size, pt.image.size, 1.0)
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
	local secs = microsecs//1000000

	local mins = secs//60
	secs = secs%60

	local hrs = mins//60
	mins = mins%60

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

	-- Initializa metadata table with default values
	local metadata = {
		player_name = (player.player_name == player_name and player.player_name or nil),
		trackid = "/org/mpris/MediaPlayer2/TrackList/NoTrack",
		artUrl = "",
		title = "TRACK",
		artist = "UNKNOWN",
		status = "STOPPED",
		position = 0,
		length = 0,
		shuffle = false,
		loop = "NONE"
	}

	-- Parse metadata
	if metadata.player_name ~= nil then
		for i, variant in ipairs(player.metadata) do
			-- If variant has key,value pair
			if #variant == 2 then
				-- Get key name (string)
				local key = variant[1]

				key = string.gsub(key, "mpris:", "")
				key = string.gsub(key, "xesam:", "")

				-- If key is a string and is in default metadata table
				if type(key) == "string" and metadata[key] ~= nil then
					-- Get value (variant)
					local value = variant[2]

					-- If value is a list, get first element as value
					if value.type == "as" then
						if #value > 0 then
							metadata[key] = value[1] or metadata[key]
						end
					-- Otherwise get value
					else
						metadata[key] = value.value or metadata[key]
					end
				end
			end
		end

		metadata.status = string.upper(player.playback_status) or metadata.status
		metadata.position = player.position or metadata.position
		metadata.shuffle = player.shuffle or metadata.shuffle
		metadata.loop = player.loop_status or metadata.loop
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
		cover_art.image.file = string.gsub(metadata.artUrl, "file://", "")

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
		icons.status.file = ((metadata.status == "PAUSED") and icon_pause or ((metadata.status == "PLAYING") and icon_play or icon_stop))

		draw_svg_icon(cr, icons.status)

		-- Draw progressbar
		local time_space = get_text_width(cr, tags.time.font, tags.time.font_size, "00:00")

		progress_bar.x = icons.status.x + icons.status.size + time_space + 2*gaps.progress + progress_bar.height/2

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

		tags.time.x = icons.status.x + icons.status.size + time_space/2 - time_width/2 + gaps.progress

		draw_text(cr, tags.time)

		-- Draw len text
		tags.time.text = microsecs_to_string(metadata.length)

		time_width = get_text_width(cr, tags.time.font, tags.time.font_size, tags.time.text)

		tags.time.x = progress_bar.x + progress_bar.width + time_space/2 - time_width/2 + gaps.progress + progress_bar.height

		draw_text(cr, tags.time)

		-- Draw shuffle/loop icons
		local icon_x = tags.time.x + time_width + 2*gaps.progress

		if show_shuffle and metadata.shuffle == true then
			icons.shuffle.x = icon_x

			draw_svg_icon(cr, icons.shuffle)

			icon_x = icon_x + icons.shuffle.size + gaps.progress
		end

		if show_loop and (metadata.loop == "TRACK" or metadata.loop == "PLAYLIST") then
			icons.loop.x = icon_x

			draw_svg_icon(cr, icons.loop)
		end

		cairo_destroy(cr)
		cairo_surface_destroy(cs)
	end
end

------------------------------------------------------------------------------
-- MOUSE EVENTS
------------------------------------------------------------------------------
function mouse_in_play_button(x, y)
	return x >= icons.status.x and x < icons.status.x + icons.status.size and y >= icons.status.y and y < icons.status.y + icons.status.size
end

function conky_mouse_events(event)
	if event.mods ~= nil then
		if event.mods.alt == false and event.mods.control == false and event.mods.super == false and event.mods.shift == false then
			if event.type == "button_down" then
				if mouse_in_play_button(event.x, event.y) then
					play_button_down = true
				end
			end

			if event.type == "button_up" and play_button_down == true then
				if mouse_in_play_button(event.x, event.y) then
					local lgi = require 'lgi'
					local playerctl = lgi.Playerctl
	
					local player = playerctl.Player()
	
					player.play_pause(player)
				end

				play_button_down = false
			end
		end
	end
end
