------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'
require 'cairo_imlib2_helper'
require 'rsvg'

------------------------------------------------------------------------------
-- CONSTANTS - DO NOT DELETE
------------------------------------------------------------------------------
local ALIGNL, ALIGNC, ALIGNR = 0, 1, 2

------------------------------------------------------------------------------
-- COLOR PALETTE
------------------------------------------------------------------------------
local palette = {
	{ name = 'adwaita_blue',   color = 0x81d0ff },
	{ name = 'adwaita_teal',   color = 0x7bdff4 },
	{ name = 'adwaita_green',  color = 0x8de698 },
	{ name = 'adwaita_yellow', color = 0xffc057 },
	{ name = 'adwaita_orange', color = 0xff9c5b },
	{ name = 'adwaita_red',    color = 0xff888c },
	{ name = 'adwaita_pink',   color = 0xffa0d8 },
	{ name = 'adwaita_purple', color = 0xfba7ff },
	{ name = 'adwaita_slate',  color = 0xbbd1e5 },

	{ name = 'nothing_orange', color = 0xfb4620 }
}

------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
---------------------------------------
-- Font/color variables
---------------------------------------
local background_color = 0x28282c
local header_color = 0xaaaaaa
local default_color = 0xffffff
local subtext_color = 0xaaaaaa

-- Read accent color from disk
local str
local accent_file = string.gsub(conky_config, 'nothing.conf', 'accent')

local f = io.open(accent_file, 'r')

if f then
	str = f:read("*all")
	f:close()
end

local accent_color = tonumber(str) or palette[1].color

local style = {
	header = {
		fface = 'Ndot 55', fsize = 36, stroke = 0, color = header_color
	},
	ring = {
		fface = 'Ndot 57', fsize = 32, stroke = 0.5, color = accent_color
	},
	text = {
		fface = 'Inter', fsize = 25, stroke = 0.6, color = default_color
	},
	subtext = {
		fface = 'Inter', fsize = 23, stroke = 0.4, color = subtext_color
	},
	time = {
		fface = 'Ndot77JPExtended', fsize = 84, stroke = 0.6, color = accent_color
	},
	weather = {
		fface = 'Ndot77JPExtended', fsize = 52, stroke = 0.3, color = accent_color
	},
	audio = {
		fface = 'Ndot77JPExtended', fsize = 44, stroke = 0.3, color = accent_color
	}
}

------------------------------------------------------------------------------
-- DEFINE WIDGETS
------------------------------------------------------------------------------
local border_radius = 36
local margin_x = 40
local margin_y = 40

local line_spacing = 22

---------------------------------------
-- CPU widget
---------------------------------------
local cpu = {
	background = {
		x = 0,
		y = 0
	},
	header = {
		label = 'CPU'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${cpu cpu0}%',
		value = '${cpu cpu0}',
		value_max = 100
	},
	text = {
		items = {
			{ label = 'CORE', value = '${hwmon coretemp temp 1}°C' }
		}
	}
}

---------------------------------------
-- MEMORY widget
---------------------------------------
local mem = {
	background = {
		x = 296,
		y = 0
	},
	header = {
		label = 'MEMORY'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${memperc}%',
		value = '${memperc}',
		value_max = 100
	},
	text = {
		items = {
			{ label = 'SWAP', value = '${swap}' }
		}
	}
}

---------------------------------------
-- DISK widget
---------------------------------------
local disk = {
	background = {
		x = 0,
		y = 318
	},
	header = {
		label = 'DISK'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${fs_used_perc /home}%',
		value = '${fs_used_perc /home}',
		value_max = 100
	},
	text = {
		items = {
			{ label = 'IO', value = '${diskio}' }
		}
	}
}

---------------------------------------
-- WIFI widget
---------------------------------------
local interface = 'wlp0s20f3'
local wifi_max = 36000

local wifi = {
	background = {
		x = 296,
		y = 318
	},
	header = {
		label = 'WIRELESS'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 100,
		mark_width = 12,
		mark_thickness = 5,
		label = '${downspeed '..interface..'}',
		value = '${downspeedf '..interface..'}',
		value_max = wifi_max
	},
	text = {
		items = {
			{ label = '${wireless_essid '..interface..'}', value = '' }
		}
	}
}

---------------------------------------
-- MULTI widget
---------------------------------------
multi = {
	horizontal = true,
	space_y = 0,
	background = {
		x = 0,
		y = 636,
		width = 690
	},
	buttons = {
		margin = 16,
		refresh = {
			size = 64,
			icon = string.gsub(conky_config, 'nothing.conf', 'weather/refresh.svg'),
			icon_size = 32,
			is_down = false
		},
		color = {
			size = 64,
			icon = string.gsub(conky_config, 'nothing.conf', 'weather/color.svg'),
			icon_size = 32,
			is_down = false
		}
	},
}

---------------------------------------
-- AUDIO widget
---------------------------------------
-- Named players (higher rank = preferred)
local named_players = {
	['Lollypop'] = { rank = 2 },
	['com.github.neithern.g4music'] = { rank = 1, alias = 'Gapless' },
	['Riff'] = { rank = 1, alias = 'Spotify' }
}

audio = {
	player = nil,
	alias = nil,
	gap_x = 32,
	show_album = true,
	background = {
		x = 0,
		y = 935,
		width = 800
	},
	cover = {
		show = true,
		icon_size = 80
	},
	ring = {
		start_angle = -200,
		end_angle = -40,
		step = 5,
		padding_x = 0,
		outer_radius = 40,
		mark_width = 8,
		mark_thickness = 4,
		label = '',
		value = 50,
		value_max = 100
	}
}
------------------------------------------------------------------------------
-- COMPUTE RING WIDGET VALUES
------------------------------------------------------------------------------
for i, w in pairs({cpu, mem, disk, wifi}) do
	w.background.width = (margin_x + w.ring.padding_x + w.ring.outer_radius) * 2

	w.header.x = w.background.x + w.background.width / 2

	w.ring.x = w.header.x
	w.ring.inner_radius = w.ring.outer_radius - w.ring.mark_width - w.ring.mark_thickness

	w.text.xs = w.background.x + margin_x
	w.text.xe = w.background.x + w.background.width - margin_x
end

------------------------------------------------------------------------------
-- AUXILIARY FUNCTIONS
------------------------------------------------------------------------------

---------------------------------------
-- Function ar_to_xy
---------------------------------------
function ar_to_xy(xc, yc, angle, radius)
	local radians = (math.pi / 180) * angle

	local x = xc + radius * (math.sin(radians))
	local y = yc - radius * (math.cos(radians))

	return x, y
end

---------------------------------------
-- Function ellipsize_text
---------------------------------------
function ellipsize_text(cr, style, text, max_width)
	-- If text fits within max width, return it as is
	if text_width(cr, style, text) <= max_width then
		return text
	end

	local out_text = text

	-- Truncate text and add ellipsis
	local ellipsis = '…'
	local ellipsis_width = text_width(cr, style, ellipsis)

	while text_width(cr, style, out_text) + ellipsis_width > max_width and #out_text > 0 do
		local chars = {}

		for c in string.gmatch(out_text, '[%z\1-\127\194-\244][\128-\191]*') do
			table.insert(chars, c)
		end

		out_text = table.concat(chars, '', 1, #chars - 2)
	end

	return out_text..ellipsis
end

---------------------------------------
-- Function microsecs_to_string
---------------------------------------
function microsecs_to_string(microsecs)
	local secs = microsecs//1000000

	local mins = secs//60
	secs = secs%60

	local hrs = mins//60
	mins = mins%60

	local str = ''

	if hrs ~= 0 then
		str = string.format('%d:%02d:%02d', hrs, mins, secs)
	else
		str = string.format('%d:%02d', mins, secs)
	end

	return str
end

------------------------------------------------------------------------------
-- WEATHER/PLAYER FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function update_player
---------------------------------------
function update_player()
	local lgi = require 'lgi'
	local Playerctl = lgi.Playerctl

	-- Find preferred player
	local rank = 0

	audio.player = nil
	audio.alias = nil

	for _, p in pairs(Playerctl.list_players()) do
		local named = named_players[p.instance]

		if named and named.rank > rank then
			audio.player = Playerctl.Player.new_from_name(p)
			audio.alias = named.alias or p.instance

			rank = named.rank
		end
	end
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------

---------------------------------------
-- Function draw_button
---------------------------------------
function draw_button(cr, btn)
	cairo_arc(cr, btn.x + btn.size/2, btn.y + btn.size/2, btn.size/2, 0, math.pi * 2)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(background_color, 1))
	cairo_fill(cr)

	local x = btn.x + (btn.size - btn.icon_size)/2
	local y = btn.y + (btn.size - btn.icon_size)/2

	draw_svg_icon(cr, btn.icon, x, y, btn.icon_size, 1)
end

---------------------------------------
-- Function draw_ring
---------------------------------------
function draw_ring(cr, ring)
	local str = conky_parse(ring.value)

	-- Calculate ring value
	local value = tonumber(str)
	if value == nil then value = 0 end

	local pct = value/ring.value_max
	pct = (pct > 1 and 1 or pct)

	local value_angle = pct * (ring.end_angle - ring.start_angle) + ring.start_angle

	-- Draw ring marks
	for angle = ring.start_angle, ring.end_angle, ring.step do
		local xs, ys = ar_to_xy(ring.x, ring.y, angle, ring.outer_radius)

		cairo_move_to(cr, xs, ys)

		local xe, ye = ar_to_xy(ring.x, ring.y, angle, ring.inner_radius)

		cairo_line_to(cr, xe, ye)

		if angle <= value_angle then
			cairo_set_source_rgba(cr, rgb_to_r_g_b(accent_color, 1))
		else
			cairo_set_source_rgba(cr, rgb_to_r_g_b(default_color, 0.05))
		end
		cairo_set_line_width(cr, ring.mark_thickness)
		cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
		cairo_stroke(cr)
	end

	-- Draw ring text
	draw_text(cr, style.ring, ALIGNC, ring.x, ring.y, ring.label)
end

---------------------------------------
-- Function draw_svg_icon
---------------------------------------
function draw_svg_icon(cr, file, x, y, size, alpha)
	cairo_save(cr)

	-- Load SVG image from file
	local handle = rsvg_create_handle_from_file(file)

	-- Position and size SVG image
	local svg_rect = RsvgRectangle:create()
	tolua.takeownership(svg_rect)

	svg_rect:set(x, y, size, size)

	-- Render SVG image on temporary canvas
	local err

	cairo_push_group(cr)
	rsvg_handle_render_document(handle, cr, svg_rect, err)

	-- Destroy objects
	tolua.releaseownership(svg_rect)
	RsvgRectangle:destroy(svg_rect)

	-- Re-color and draw SVG image
	local pattern = cairo_pop_group(cr)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(default_color, alpha))

	cairo_mask(cr, pattern)

	cairo_pattern_destroy(pattern)

	rsvg_destroy_handle(handle)

	cairo_restore(cr)
end

---------------------------------------
-- Function draw_audio_cover
---------------------------------------
function draw_audio_cover(cr, x, y, cover)
	if (cover.show == false or cover.file == nil or cover.file == '') then
		-- Draw audio icon
		local icon = string.gsub(conky_config, 'nothing.conf', 'audio/audio.svg')

		local xi = x + (cover.size - cover.icon_size)/2
		local yi = y + (cover.size - cover.icon_size)/2

		draw_svg_icon(cr, icon, xi, yi, cover.icon_size, 0.2)
	else
		-- Draw cover from file
		cairo_save(cr)
		cairo_arc(cr, x + cover.size/2, y + cover.size/2, cover.size/2, 0, math.pi * 2)
		cairo_clip(cr)
		cairo_place_image(cover.file, cr, x, y, cover.size, cover.size, 1)
		cairo_restore(cr)
	end
end

------------------------------------------------------------------------------
-- WIDGET FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_ring_widgets
---------------------------------------
function draw_ring_widgets(cr)
	for i, w in pairs({cpu, mem, disk, wifi}) do
		-- Compute widget values
		w.background.height = style.header.height + line_spacing + w.ring.outer_radius + (line_spacing + style.text.height) * #w.text.items + line_spacing * 2 + margin_y * 2
		w.header.y = w.background.y + margin_y + style.header.height
		w.ring.y = w.header.y + line_spacing * 2 + w.ring.outer_radius

		-- Draw background
		draw_background(cr, w.background)

		-- Draw header
		draw_text(cr, style.header, ALIGNC, w.header.x, w.header.y, w.header.label)

		-- Draw ring with label
		draw_ring(cr, w.ring)

		-- Draw text
		for i, item in pairs(w.text.items) do
			local y = w.ring.y + line_spacing + (line_spacing + style.text.height) * i

			draw_text(cr, style.text, ALIGNL, w.text.xs, y, item.label, w.text.xe - w.text.xs)
			draw_text(cr, style.text, ALIGNR, w.text.xe, y, item.value, w.text.xe - w.text.xs)
		end
	end
end

---------------------------------------
-- Function draw_multi_widget
---------------------------------------
function draw_multi_widget(cr)
	-- Compute widget values
	if multi.horizontal then
		multi.background.height = line_spacing * 4 + style.text.height * 2 + style.subtext.height + style.time.height + margin_y * 2
	else
		multi.background.height = line_spacing * 8.5 + style.text.height * 3 + style.subtext.height * 3 + style.time.height + style.weather.height + multi.space_y + margin_y * 2
	end

	multi.buttons.refresh.x = multi.background.x + multi.background.width + multi.buttons.margin
	multi.buttons.refresh.y = multi.background.y
	multi.buttons.color.x = multi.buttons.refresh.x
	multi.buttons.color.y = multi.buttons.refresh.y + multi.buttons.refresh.size + multi.buttons.margin

	-- Draw buttons
	draw_button(cr, multi.buttons.refresh)
	draw_button(cr, multi.buttons.color)



end

---------------------------------------
-- Function draw_audio_widget
---------------------------------------
function draw_audio_widget(cr)
	-- Get player cover art
	local url = audio.player:print_metadata_prop('mpris:artUrl')

	url = (audio.player.playback_status == 'STOPPED' and '' or url)

	local cover_file = nil

	if url ~= nil then
		if string.find(url, '^file://') then
			cover_file = string.gsub(url, 'file://', '')
		elseif string.find(url, '^http') then
			local file = '/tmp/conky_nothing_cover'

			local handle = io.popen('curl -s "'..url..'"')
			local str = handle:read('*a')
			handle:close()

			io.output(file)
			io.write(str)
			io.output():close()

			cover_file = file
		end
	end

	if cover_file ~= audio.cover.file then
		audio.cover.file = cover_file
	end

	-- Get player metadata
	local title = audio.player.playback_status == 'STOPPED' and 'No Track' or (audio.player:get_title() or 'Track')

	local subtitle = audio.player.playback_status == 'STOPPED' and '---' or (audio.player:get_artist() or 'Unknown Artist')

	local album = audio.player:get_album()

	if audio.show_album and subtitle and subtitle ~= '---' and album and album ~= '' then
		subtitle = subtitle..'  •  '..album
	end

	-- Get player position/track length
	local pos = audio.player.position or 0
	local len_str = audio.player:print_metadata_prop('mpris:length')
	local len = len_str and tonumber(len_str) or 0

	-- Compute widget values
	audio.cover.size = style.audio.height + style.text.height + style.subtext.height * 2 + line_spacing * 4

	audio.ring.inner_radius = audio.cover.size/2 + audio.gap_x/2
	audio.ring.outer_radius = audio.ring.inner_radius + audio.ring.mark_width + audio.ring.mark_thickness
	audio.ring.value = (len == 0 and 0 or pos/len * 100)

	audio.background.height = audio.ring.outer_radius + audio.cover.size/2 + margin_y * 2

	-- Draw background
	draw_background(cr, audio.background)

	-- Draw ring
	local x = audio.background.x + margin_x + audio.ring.outer_radius
	local y = audio.background.y + margin_y + audio.cover.size/2

	audio.ring.x = x
	audio.ring.y = y

	draw_ring(cr, audio.ring)

	-- Draw cover art
	x = x - audio.cover.size/2
	y = y - audio.cover.size/2

	draw_audio_cover(cr, x, y, audio.cover)

	-- Draw heading
	x = x + audio.cover.size + audio.gap_x * 1.5
	y = y + style.subtext.height

	draw_text(cr, style.subtext, ALIGNL, x, y, audio.alias)

	-- Draw metadata
	y = y + style.audio.height + line_spacing * 1.5

	local max_width = audio.background.width - x - margin_x

	draw_text(cr, style.audio, ALIGNL, x, y, title, max_width)

	y = y + line_spacing + style.text.height

	draw_text(cr, style.text, ALIGNL, x, y, subtitle, max_width)

	-- Draw status
	local time_w = text_width(cr, style.subtext, '0:00')
	local stopped_w = text_width(cr, style.subtext, 'STOPPED')

	y = y + line_spacing * 1.5 + style.subtext.height

	draw_text(cr, style.subtext, ALIGNL, x, y, audio.player.playback_status)

	x = x + stopped_w + audio.gap_x + time_w

	draw_text(cr, style.subtext, ALIGNR, x, y, microsecs_to_string(pos))

	local dx = draw_text(cr, style.subtext, ALIGNL, x, y, '  •  ')

	x = x + dx

	draw_text(cr, style.subtext, ALIGNL, x, y, microsecs_to_string(len))
end

------------------------------------------------------------------------------
-- STARTUP FUNCTION
------------------------------------------------------------------------------
function conky_startup()
	-- Update weather data
	update_weather()
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Create cairo context
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Compute style font heights
	style.text.height = font_height(cr, style.text)
	style.subtext.height = font_height(cr, style.subtext)
	style.header.height = font_height(cr, style.header)
	style.weather.height = font_height(cr, style.weather)
	style.time.height = font_height(cr, style.time)

	-- Draw ring widgets
	draw_ring_widgets(cr)

	-- Update active player
	update_player()
	
	-- Draw audio widget
	if audio.player then
		-- Compute style font heights
		style.audio.height = font_height(cr, style.audio)

		draw_audio_widget(cr)
	end

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end

------------------------------------------------------------------------------
-- SHUTDOWN FUNCTION
------------------------------------------------------------------------------
function conky_shutdown()
	local str = string.format('0x%x', accent_color)

	io.output(string.gsub(conky_config, 'nothing.conf', 'accent'))
	io.write(str)
	io.output():close()
end

------------------------------------------------------------------------------
-- MOUSE EVENTS
------------------------------------------------------------------------------
function mouse_in_button(event, btn)
	return event.x >= btn.x and event.x < btn.x + btn.size and event.y >= btn.y and event.y < btn.y + btn.size
end

function conky_mouse(event)
	if event.type ~= 'button_down' and event.type ~= 'button_up' then return end
	
	if event.button ~= 'left' or event.mods.alt or event.mods.control or event.mods.super then return end

	if mouse_in_button(event, multi.buttons.refresh) and event.mods.shift == false then
		if event.type == 'button_down' then
			multi.buttons.refresh.is_down = true
		elseif event.type == 'button_up' and multi.buttons.refresh.is_down then
			update_weather()

			multi.buttons.refresh.is_down = false
		end
	elseif mouse_in_button(event, multi.buttons.color) then
		if event.type == 'button_down' then
			multi.buttons.color.is_down = true
		elseif event.type == 'button_up' and multi.buttons.color.is_down then
			local index = 0

			for i, v in ipairs(palette) do
				if accent_color == v.color then
					index = i
				end
			end

			if index == 0 then
				index = (event.mods.shift and #palette or 1)
			else
				if event.mods.shift then
					index = (index == 1 and #palette or (index - 1))
				else
					index = (index == #palette and 1 or (index + 1))
				end
			end

			accent_color = palette[index].color

			style.ring.color = accent_color
			style.time.color = accent_color
			style.weather.color = accent_color
			style.audio.color = accent_color
			
			multi.buttons.color.is_down = false
		end
	end
end
