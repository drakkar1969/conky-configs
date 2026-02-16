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
	adwaita_blue = 0x81d0ff,
	adwaita_teal = 0x7bdff4,
	adwaita_green = 0x8de698,
	adwaita_yellow = 0xffc057,
	adwaita_orange = 0xff9c5b,
	adwaita_red = 0xff888c,
	adwaita_pink = 0xffa0d8,
	adwaita_purple = 0xfba7ff,
	adwaita_slate = 0xbbd1e5,

	nothing_orange = 0xfb4620
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
local subtext_color = 0xbbbbbb
local accent_color = palette.adwaita_yellow

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
	audio_title = {
		fface = 'Ndot77JPExtended', fsize = 44, stroke = 0.3, color = accent_color
	},
	audio_subtitle = {
		fface = 'Inter', fsize = 25, stroke = 0.6, color = default_color
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
		outer_radius = 105,
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
		x = 315,
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
		outer_radius = 105,
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
		y = 335
	},
	header = {
		label = 'DISK'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 105,
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
		x = 315,
		y = 335
	},
	header = {
		label = 'WIRELESS'
	},
	ring = {
		start_angle = -90,
		end_angle = 90,
		step = 9,
		padding_x = 0,
		outer_radius = 105,
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
-- TIME widget
---------------------------------------
time = {
	background = {
		x = 0,
		y = 670,
		width = 605
	},
	weather = {
		app_id = 'b1b61a08efe33de67901d98c4f5711f5',
		city = 'Krakow,PL',
		interval = 900,
		icon_size = 64,
		icon_gap_x = 20,
		icon_dy = 2,
		icon = '',
		location = '',
		description = '',
		temperature = '-',
		feels_like = '-'
	}
}

---------------------------------------
-- AUDIO widget
---------------------------------------
-- Named players (higher rank = preferred)
local named_players = {
	["Lollypop"] = { rank = 2 },
	["com.github.neithern.g4music"] = { rank = 1, alias = "Gapless" },
	["Riff"] = { rank = 1, alias = "Spotify" }
}

audio = {
	player = nil,
	alias = nil,
	gap_x = 32,
	background = {
		x = 0,
		y = 980,
		width = 800
	},
	cover = {
		show = true,
		icon_size = 64
	},
	ring = {
		start_angle = -200,
		end_angle = -40,
		step = 6,
		padding_x = 0,
		outer_radius = 40,
		mark_width = 6,
		mark_thickness = 4,
		label = '',
		value = 50,
		value_max = 100
	}
}
------------------------------------------------------------------------------
-- COMPUTE WIDGET VALUES
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
-- Function rgb_to_r_g_b
---------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

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
-- Function font_height
---------------------------------------
function font_height(cr, style)
	cairo_select_font_face(cr, style.fface, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, style.fsize)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	local height = f_extents.height - f_extents.descent * 2

	tolua.releaseownership(f_extents)
	cairo_font_extents_t:destroy(f_extents)

	return height
end

---------------------------------------
-- Function text_width
---------------------------------------
function text_width(cr, style, text)
	cairo_select_font_face(cr, style.fface, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, style.fsize)

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local width = t_extents.x_advance

	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)

	return width
end

---------------------------------------
-- Function accented_upper
---------------------------------------
function accented_upper(text)
	-- Accented character map
	local accented_map = {
		["á"] = "Á", ["é"] = "É", ["í"] = "Í", ["ó"] = "Ó", ["ú"] = "Ú",
		["à"] = "À", ["è"] = "È", ["ì"] = "Ì", ["ò"] = "Ò", ["ù"] = "Ù",
		["â"] = "Â", ["ê"] = "Ê", ["î"] = "Î", ["ô"] = "Ô", ["û"] = "Û",
		["ä"] = "Ä", ["ë"] = "Ë", ["ï"] = "Ï", ["ö"] = "Ö", ["ü"] = "Ü",
		["ã"] = "Ã", ["õ"] = "Õ", ["ñ"] = "Ñ", ["ç"] = "Ç"
	}

	text = string.upper(text)

	return (string.gsub(text, "[%z\1-\127\194-\244][\128-\191]*", function(char)
		return accented_map[char] or char
	end))
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
	local ellipsis = "…"
	local ellipsis_width = text_width(cr, style, ellipsis)

	while text_width(cr, style, out_text) + ellipsis_width > max_width and #out_text > 0 do
		out_text = string.sub(out_text, 1, -2)
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

	local str = ""

	if hrs ~= 0 then
		str = string.format("%d:%02d:%02d", hrs, mins, secs)
	else
		str = string.format("%d:%02d", mins, secs)
	end

	return str
end

------------------------------------------------------------------------------
-- WEATHER/PLAYER FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function update_weather
---------------------------------------
function update_weather()
	local json = require("dkjson")

	-- Download weather data
	local url = 'api.openweathermap.org/data/2.5/weather?q='..time.weather.city..'&appid='..time.weather.app_id..'&units=metric'

	local handle = io.popen('curl -s "'..url..'"')
	local str = handle:read("*a")
	handle:close()

	-- Decode weather data from json
	local data, pos, err = json.decode(str, 1, nil)

	time.weather.location = (data ~= nil and data.name or '')
	time.weather.description = (data.weather[1] ~= nil and data.weather[1].main or '')
	time.weather.temperature = ((data.main ~= nil and data.main.temp ~= nil) and tostring(math.floor(tonumber(data.main.temp) + 0.5)) or '-')
	time.weather.feels_like = ((data.main ~= nil and data.main.feels_like ~= nil) and tostring(math.floor(tonumber(data.main.feels_like) + 0.5)) or '-')

	local icon = (data.weather[1] ~= nil and data.weather[1].icon or '')
	time.weather.icon = (icon ~= nil and string.gsub(conky_config, 'nothing.conf', 'weather/'..icon..'.png') or '')
end

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

		if named ~= nil and named.rank > rank then
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
-- Function draw_background
---------------------------------------
function draw_background(cr, pt)
	local conv = math.pi / 180

	cairo_new_sub_path(cr)
	cairo_arc(cr, pt.x + pt.width - border_radius, pt.y + border_radius, border_radius, -90 * conv, 0)
	cairo_arc(cr, pt.x + pt.width - border_radius, pt.y + pt.height - border_radius, border_radius, 0, 90 * conv)
	cairo_arc(cr, pt.x + border_radius, pt.y + pt.height - border_radius, border_radius, 90 * conv, 180 * conv);
	cairo_arc(cr, pt.x + border_radius, pt.y + border_radius, border_radius, 180 * conv, 270 * conv);
	cairo_close_path(cr)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(background_color, 1))
	cairo_fill(cr)
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr, style, align, x, y, text, max_width)
	text = accented_upper(conky_parse(text))

	-- Ellipsize text if necessary
	if max_width ~= nil then
		text = ellipsize_text(cr, style, text, max_width)
	end

	-- Set font/color
	cairo_select_font_face(cr, style.fface, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, style.fsize)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(style.color, 1))

	-- Calculate text extents
	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local text_w = t_extents.x_advance

	local text_x = ((align == ALIGNR) and (x - text_w) or ((align == ALIGNC) and (x - text_w * 0.5) or x))

	-- Draw text
	cairo_move_to(cr, text_x, y)
	cairo_text_path(cr, text)
	cairo_set_line_width(cr, style.stroke)
	cairo_stroke_preserve(cr)
	cairo_fill(cr)

	-- Destroy variables
	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)

	return text_w
end

---------------------------------------
-- Function draw_ring
---------------------------------------
function draw_ring(cr, pt)
	local str = conky_parse(pt.value)

	-- Calculate ring value
	local value = tonumber(str)
	if value == nil then value = 0 end

	local pct = value/pt.value_max
	pct = (pct > 1 and 1 or pct)

	local value_angle = pct * (pt.end_angle - pt.start_angle) + pt.start_angle

	-- Draw ring marks
	for angle = pt.start_angle, pt.end_angle, pt.step do
		local xs, ys = ar_to_xy(pt.x, pt.y, angle, pt.outer_radius)

		cairo_move_to(cr, xs, ys)

		local xe, ye = ar_to_xy(pt.x, pt.y, angle, pt.inner_radius)

		cairo_line_to(cr, xe, ye)

		if angle <= value_angle then
			cairo_set_source_rgba(cr, rgb_to_r_g_b(accent_color, 1))
		else
			cairo_set_source_rgba(cr, rgb_to_r_g_b(default_color, 0.05))
		end
		cairo_set_line_width(cr, pt.mark_thickness)
		cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
		cairo_stroke(cr)
	end

	-- Draw ring text
	draw_text(cr, style.ring, ALIGNC, pt.x, pt.y, pt.label)
end

---------------------------------------
-- Function draw_svg_icon
---------------------------------------
function draw_svg_icon(cr, file, x, y, size)
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

	cairo_set_source_rgba(cr, rgb_to_r_g_b(default_color, 0.2))

	cairo_mask(cr, pattern)

	cairo_pattern_destroy(pattern)

	rsvg_destroy_handle(handle)

	cairo_restore(cr)
end

---------------------------------------
-- Function draw_audio_cover
---------------------------------------
function draw_audio_cover(cr, x, y, cover)
	-- Draw audio icon
	if (cover.show == false or cover.file == nil or cover.file == "") then
		local icon = string.gsub(conky_config, 'nothing.conf', 'audio/audio.svg')

		local xi = x + (cover.size - cover.icon_size)/2
		local yi = y + (cover.size - cover.icon_size)/2

		draw_svg_icon(cr, icon, xi, yi, cover.icon_size)
	-- Draw cover
	else
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
-- Function draw_time_widget
---------------------------------------
function draw_time_widget(cr)
	-- Compute widget values
	time.background.height = line_spacing * 4 + style.text.height * 3 + style.time.height + margin_y * 2

	-- Draw background
	draw_background(cr, time.background)

	-- Draw weather icon
	local xs = time.background.x + margin_x
	local xe = time.background.x + time.background.width - margin_x
	local y = time.background.y + margin_y + style.weather.height + line_spacing * 0.5

	if time.weather.icon ~= '' then
		cairo_place_image(time.weather.icon, cr, xs, y - style.weather.height/2 - time.weather.icon_size/2 + time.weather.icon_dy, time.weather.icon_size, time.weather.icon_size, 1)
	end

	-- Draw weather temperature text
	draw_text(cr, style.weather, ALIGNL, xs + time.weather.icon_size + time.weather.icon_gap_x, y, time.weather.temperature..'°C')

	if time.weather.feels_like ~= '-' then
		y = y + line_spacing * 1.25 + style.text.height

		draw_text(cr, style.subtext, ALIGNL, xs, y, 'Feels like '..time.weather.feels_like..'°C')
	end

	-- Draw date/time text
	y = time.background.y + margin_y + style.text.height

	draw_text(cr, style.text, ALIGNR, xe, y, '${time %a %d %b}')

	y = y + line_spacing + style.time.height

	draw_text(cr, style.time, ALIGNR, xe, y, '${time %R}')

	-- Draw battery/weather text
	y = y + line_spacing * 2 + style.text.height

	draw_text(cr, style.text, ALIGNL, xs, y, time.weather.description)
	draw_text(cr, style.text, ALIGNR, xe, y, '${battery_percent BAT0}% BATT')

	y = y + line_spacing + style.text.height

	draw_text(cr, style.subtext, ALIGNL, xs, y, time.weather.location)
	draw_text(cr, style.subtext, ALIGNR, xe, y, '${battery_status BAT0}')
end

---------------------------------------
-- Function draw_audio_widget
---------------------------------------
function draw_audio_widget(cr)
	-- Get player cover art
	local cover_url = audio.player:print_metadata_prop("mpris:artUrl") or ""

	if string.find(cover_url, "^http") then
		audio.cover.file = nil
	else
		audio.cover.file = string.gsub(cover_url, "file://", "")
	end

	-- Get player metadata
	local title = audio.player.playback_status == "STOPPED" and "No Track" or (audio.player:get_title() or "Track")

	local subtitle = audio.player.playback_status == "STOPPED" and "---" or (audio.player:get_artist() or "Unknown Artist")

	local album = audio.player:get_album()

	if subtitle ~= nil and subtitle ~= '---' and album ~= nil and album ~= "" then
		subtitle = subtitle.."  •  "..album
	end

	-- Get player position/track length
	local pos = audio.player.position or 0
	local len_str = audio.player:print_metadata_prop("mpris:length")
	local len = len_str ~= nil and tonumber(len_str) or 0

	-- Compute widget values
	audio.cover.size = style.audio_title.height + style.audio_subtitle.height + style.subtext.height * 2 + line_spacing * 4

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
	x = x + audio.cover.size + audio.gap_x
	y = y + style.subtext.height

	draw_text(cr, style.subtext, ALIGNL, x, y, audio.alias)

	-- Draw metadata
	y = y + style.audio_title.height + line_spacing * 1.5

	local max_width = audio.background.width - x - margin_x

	draw_text(cr, style.audio_title, ALIGNL, x, y, title, max_width)

	y = y + line_spacing + style.audio_subtitle.height

	draw_text(cr, style.audio_subtitle, ALIGNL, x, y, subtitle, max_width)

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

	-- Update weather if necessary
	local updates = tonumber(conky_parse("${updates}"))

	if updates ~= 0 and updates % time.weather.interval == 0 then
		update_weather()
	end

	-- Draw time widget
	draw_time_widget(cr)

	-- Update active player
	update_player()
	
	-- Draw audio widget
	if audio.player ~= nil then
		-- Compute style font heights
		style.audio_title.height = font_height(cr, style.audio_title)
		style.audio_subtitle.height = font_height(cr, style.audio_subtitle)

		draw_audio_widget(cr)
	end

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
