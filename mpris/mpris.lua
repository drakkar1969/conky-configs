------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
-- Allowed players (higher number = preferred)
allowed_players = {
	Lollypop = 2,
	G4Music = 1
}
-- Light/dark colors
dark_colors = true

-- Show album
show_album = true

-- Progress bar dot (false = full progress bar)
progress_dot = false
progress_square = false

-- Show cover art
show_cover_art = true

-- Show shuffle/loop icons
show_shuffle = true
show_loop = true

-- Icon assets
icon_play = string.gsub(conky_config, 'mpris.conf', 'icons/play.svg')
icon_pause = string.gsub(conky_config, 'mpris.conf', 'icons/pause.svg')
icon_stop = string.gsub(conky_config, 'mpris.conf', 'icons/stop.svg')
icon_previous = string.gsub(conky_config, 'mpris.conf', 'icons/previous.svg')
icon_previous_disabled = string.gsub(conky_config, 'mpris.conf', 'icons/previous-disabled.svg')
icon_next = string.gsub(conky_config, 'mpris.conf', 'icons/next.svg')
icon_next_disabled = string.gsub(conky_config, 'mpris.conf', 'icons/next-disabled.svg')
icon_audio = string.gsub(conky_config, 'mpris.conf', 'icons/audio.svg')
icon_shuffle = string.gsub(conky_config, 'mpris.conf', 'icons/shuffle.svg')
icon_loop_track = string.gsub(conky_config, 'mpris.conf', 'icons/loop-track.svg')
icon_loop_playlist = string.gsub(conky_config, 'mpris.conf', 'icons/loop-playlist.svg')

-- Font/color variables
main_font = "Ubuntu"
main_color = dark_colors and 0x3d3846 or 0xdeddda
hilight_color = dark_colors and 0x241f31 or 0xc0bfbc

-- Element spacing
gaps = { tags = 14, progress = 10, y = 14 }

-- Cover art
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
		font = main_font,
		font_size = 12,
		bold = true,
		italic = false,
		color = main_color,
		alpha = 0.5
	},	
	-- Track title
	title = {
		font = main_font,
		font_size = 24,
		bold = false,
		italic = false,
		color = main_color,
		alpha = 1,
	},
	-- Track artist
	artist = {
		font = main_font,
		font_size = 15,
		bold = false,
		italic = false,
		color = hilight_color,
		alpha = 1,
	},
	-- Track position
	time = {
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
	previous = {
		size = 16,
		color = main_color,
		alpha = dark_colors and 0.85 or 0.9,
		file = icon_previous_disabled
	},
	next = {
		size = 16,
		color = main_color,
		alpha = dark_colors and 0.85 or 0.9,
		file = icon_next_disabled
	},
	shuffle = {
		size = 16,
		color = main_color,
		alpha = dark_colors and 0.85 or 0.9,
		file = icon_shuffle
	},
	loop = {
		size = 16,
		color = main_color,
		alpha = dark_colors and 0.85 or 0.9,
		file = icon_loop_track
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
previous_button_down = false
next_button_down = false

------------------------------------------------------------------------------
-- ACCENTED CHARACTER MAP (UPDATE AS NECESSARY)
------------------------------------------------------------------------------
accented_map = {
	["á"] = "Á", ["é"] = "É", ["í"] = "Í", ["ó"] = "Ó", ["ú"] = "Ú",
	["à"] = "À", ["è"] = "È", ["ì"] = "Ì", ["ò"] = "Ò", ["ù"] = "Ù",
	["â"] = "Â", ["ê"] = "Ê", ["î"] = "Î", ["ô"] = "Ô", ["û"] = "Û",
	["ä"] = "Ä", ["ë"] = "Ë", ["ï"] = "Ï", ["ö"] = "Ö", ["ü"] = "Ü",
	["ã"] = "Ã", ["õ"] = "Õ",
	["ñ"] = "Ñ",
	["ç"] = "Ç"
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
divider.xs = cover_art.frame.x + cover_art.frame.size + gaps.tags + divider.width/2
divider.ys = cover_art.frame.y
divider.xr = 0
divider.yr = cover_art.frame.size

-- Calculate icon positions (some x coordinates calculated in main function)
temp_height = math.max(icons.status.size, icons.shuffle.size, icons.loop.size, progress_bar.height)

icons.previous.x = cover_art.frame.x
icons.previous.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - icons.previous.size)/2

icons.status.x = icons.previous.x + icons.previous.size + gaps.progress
icons.status.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - icons.status.size)/2

icons.next.x = icons.status.x + icons.status.size + gaps.progress
icons.next.y = cover_art.frame.y + cover_art.frame.size + gaps.y + (temp_height - icons.next.size)/2

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

function get_text_width(cr, pt, text)
	cairo_save(cr)

	local slant = (pt.italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL)
	local weight = (pt.bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)

	cairo_select_font_face(cr, pt.font, slant, weight)
	cairo_set_font_size(cr, pt.font_size)

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local retval = (t_extents.width - t_extents.x_bearing)

	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)

	cairo_restore(cr)

	return retval
end

function get_font_height(cr, pt)
	cairo_save(cr)

	local slant = (pt.italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL)
	local weight = (pt.bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)

	cairo_select_font_face(cr, pt.font, slant, weight)
	cairo_set_font_size(cr, pt.font_size)

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
function draw_text(cr, pt, text)
	local slant = (pt.italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL)
	local weight = (pt.bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)

	cairo_select_font_face(cr, pt.font, slant, weight)
	cairo_set_font_size(cr, pt.font_size)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))

	cairo_move_to(cr, pt.x, pt.y)
	cairo_show_text(cr, text)
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
-- PLAYING INFO
------------------------------------------------------------------------------
function get_playing_info()
	local lgi = require 'lgi'
	local Playerctl = lgi.Playerctl

	-- Initalize playing info with default values
	local playing_info = {
		player_name = nil,
		metadata = {
			artUrl = "",
			title = "TRACK",
			artist = "UNKOWN ARTIST",
			album = "UNKNOWN ALBUM",
			length = 0,
		},
		status = "STOPPED"
	}

	-- Find preferred player
	local pref_player = nil
	local top_rank = 0

	for _, plr in pairs(Playerctl.list_players()) do
		local player_rank = allowed_players[plr.name]

		if player_rank ~= nil and player_rank > top_rank then
			local player = Playerctl.Player.new_from_name(plr)

			pref_player = player
			top_rank = player_rank
		end
	end

	-- Get playing info
	if pref_player ~= nil then
		-- Get player name
		playing_info.player_name = pref_player.player_name

		-- Parse metadata
		if string.upper(pref_player.playback_status) ~= playing_info.status then
			for i, variant in ipairs(pref_player.metadata) do
				-- Get key name (string)
				local key = variant[1]

				key = string.gsub(key, "mpris:", "")
				key = string.gsub(key, "xesam:", "")

				-- If key is in default metadata table
				if playing_info.metadata[key] ~= nil then
					-- Get key value
					local value = variant[2]

					-- If value is a list, get first element as value
					if value.type == "as" then
						playing_info.metadata[key] = value[1] or playing_info.metadata[key]
					-- Otherwise get value
					else
						playing_info.metadata[key] = value.value or playing_info.metadata[key]
					end
				end
			end
		end

		-- Get player status
		playing_info.status = string.upper(pref_player.playback_status) or "STOPPED"
		playing_info.position = pref_player.position or 0
		playing_info.shuffle = pref_player.shuffle or false
		playing_info.loop = pref_player.loop_status or "NONE"
		playing_info.can_go_previous = pref_player.can_go_previous or false
		playing_info.can_go_next = pref_player.can_go_next or false

		if playing_info.status == "STOPPED" then
			playing_info.metadata.title = "NO TRACK"
			playing_info.metadata.artist = "(NONE)"
		end
	end

	return playing_info
end

------------------------------------------------------------------------------
-- HELPER FUNCTIONS
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

function accented_upper(text)
	return (text:gsub("[%z\1-\127\194-\244][\128-\191]*", function(char)
		return accented_map[char] or char
	end))
end

function ellipsize_text(cr, pt, text, max_width)
	local out_text = string.upper(text)

	-- If text fits within max width, return it as is
	if get_text_width(cr, pt, out_text) <= max_width then
		return accented_upper(out_text)
	end

	-- Truncate text and add ellipsis
	local ellipsis = "..."
	local ellipsis_width = get_text_width(cr, pt, ellipsis)

	local truncated_text = out_text

	while get_text_width(cr, pt, truncated_text) + ellipsis_width > max_width and #truncated_text > 0 do
		truncated_text = truncated_text:sub(1, -2)
	end

	return accented_upper(truncated_text)..ellipsis
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Get playing info
	local playing_info = get_playing_info()

	if playing_info.player_name ~= nil then
		local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

		local cr = cairo_create(cs)

		-- Draw header
		draw_text(cr, tags.header, string.upper(playing_info.player_name))

		-- Draw cover with frame
		cover_art.image.file = string.gsub(playing_info.metadata.artUrl, "file://", "")

		draw_cover(cr, cover_art)

		-- Draw vertical line
		draw_rel_line(cr, divider)

		-- Draw track title/artist tags
		if show_album then
			playing_info.metadata.artist = playing_info.metadata.artist.."  •  "..playing_info.metadata.album
		end

		title = ellipsize_text(cr, tags.title, playing_info.metadata.title, conky_window.width - tags.title.x - 10)
		artist = ellipsize_text(cr, tags.artist, playing_info.metadata.artist, conky_window.width - tags.artist.x - 10)

		local title_height = get_font_height(cr, tags.title)
		local artist_height = get_font_height(cr, tags.artist)

		local tag_spacing = (cover_art.frame.size - title_height - artist_height)/3

		tags.title.y = cover_art.frame.y + title_height + tag_spacing
		tags.artist.y = tags.title.y + artist_height + tag_spacing

		draw_text(cr, tags.title, title)
		draw_text(cr, tags.artist, artist)

		-- Draw previous icon
		icons.previous.file = (playing_info.can_go_previous and icon_previous or icon_previous_disabled)

		draw_svg_icon(cr, icons.previous)

		-- Draw status icon
		icons.status.file = ((playing_info.status == "PAUSED") and icon_play or ((playing_info.status == "PLAYING") and icon_pause or icon_stop))

		draw_svg_icon(cr, icons.status)

		-- Draw next icon
		icons.next.file = (playing_info.can_go_next and icon_next or icon_next_disabled)

		draw_svg_icon(cr, icons.next)

		-- Draw progressbar
		local time_space = get_text_width(cr, tags.time, "00:00")

		progress_bar.x = icons.next.x + icons.next.size + time_space + 3*gaps.progress + progress_bar.height/2

		if playing_info.metadata.length == 0 then
			progress_bar.pct = 0
		else
			progress_bar.pct = tonumber(playing_info.position)/tonumber(playing_info.metadata.length)
		end

		draw_bar(cr, progress_bar)

		-- Draw position text
		position = microsecs_to_string(playing_info.position)

		local time_width = get_text_width(cr, tags.time, position)
		local time_height = get_font_height(cr, tags.time)
		
		tags.time.x = icons.next.x + icons.next.size + time_space/2 - time_width/2 + 2*gaps.progress
		tags.time.y = progress_bar.y + time_height/2

		draw_text(cr, tags.time, position)

		-- Draw length text
		length = microsecs_to_string(playing_info.metadata.length)

		time_width = get_text_width(cr, tags.time, length)

		tags.time.x = progress_bar.x + progress_bar.width + time_space/2 - time_width/2 + gaps.progress + progress_bar.height

		draw_text(cr, tags.time, length)

		-- Draw shuffle icon
		local icon_x = tags.time.x + time_width + 2*gaps.progress

		if show_shuffle and playing_info.shuffle == true then
			icons.shuffle.x = icon_x

			draw_svg_icon(cr, icons.shuffle)

			icon_x = icon_x + icons.shuffle.size + gaps.progress
		end

		-- Draw loop icon
		if show_loop and (playing_info.loop == "TRACK" or playing_info.loop == "PLAYLIST") then
			icons.loop.x = icon_x

			if playing_info.loop == "TRACK" then
				icons.loop.file = icon_loop_track
			else
				icons.loop.file = icon_loop_playlist
			end

			draw_svg_icon(cr, icons.loop)
		end

		cairo_destroy(cr)
		cairo_surface_destroy(cs)
	end
end

------------------------------------------------------------------------------
-- MOUSE EVENTS
------------------------------------------------------------------------------
function mouse_over_icon(x, y, icon)
	return x >= icon.x and x < icon.x + icon.size and y >= icon.y and y < icon.y + icon.size
end

function conky_mouse_events(event)
	if event.mods ~= nil then
		if event.mods.alt == false and event.mods.control == false and event.mods.super == false and event.mods.shift == false then
			if event.type == "button_down" then
				if mouse_over_icon(event.x, event.y, icons.status) then
					play_button_down = true
				end

				if icons.previous.file == icon_previous and mouse_over_icon(event.x, event.y, icons.previous) then
					previous_button_down = true
				end

				if icons.next.file == icon_next and mouse_over_icon(event.x, event.y, icons.next) then
					next_button_down = true
				end
			end

			if event.type == "button_up" then
				if mouse_over_icon(event.x, event.y, icons.status) and play_button_down == true then
					local lgi = require 'lgi'
					local Playerctl = lgi.Playerctl
	
					local player = Playerctl.Player()
	
					player.play_pause(player)
				end

				if mouse_over_icon(event.x, event.y, icons.previous) and previous_button_down == true then
					local lgi = require 'lgi'
					local Playerctl = lgi.Playerctl
	
					local player = Playerctl.Player()
	
					player.previous(player)
				end

				if mouse_over_icon(event.x, event.y, icons.next) and next_button_down == true then
					local lgi = require 'lgi'
					local Playerctl = lgi.Playerctl
	
					local player = Playerctl.Player()
	
					player.next(player)
				end

				play_button_down = false
				previous_button_down = false
				next_button_down = false
			end
		end
	end
end
