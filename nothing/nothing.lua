------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'
require 'cairo_imlib2_helper'

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
	}
}

---------------------------------------
-- Weather variables
---------------------------------------
local weather = {
	app_id = 'b1b61a08efe33de67901d98c4f5711f5',
	city = 'Krakow,PL',
	interval = 900,
	icon_size = 64,
	icon_gap = 20,
	icon_dy = 2,
	icon = '',
	location = '',
	description = '',
	temperature = '-',
	feels_like = '-'
}

------------------------------------------------------------------------------
-- DEFINE WIDGETS
------------------------------------------------------------------------------
local border_radius = 36
local margin_x = 40
local margin_y = 50

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
		mark_width = 16,
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
		mark_width = 16,
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
		y = 355
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
		mark_width = 16,
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
		y = 355
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
		mark_width = 16,
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
		y = 710,
		width = 605
	}
}

------------------------------------------------------------------------------
-- COMPUTE WIDGET VALUES
------------------------------------------------------------------------------
for i, w in pairs({cpu, mem, disk, wifi}) do
	w.background.width = (margin_x + w.ring.padding_x + w.ring.outer_radius) * 2

	w.header.x = w.background.x + w.background.width / 2

	w.ring.x = w.header.x
	w.ring.inner_radius = w.ring.outer_radius - w.ring.mark_width

	w.text.xs = w.background.x + margin_x
	w.text.xe = w.background.x + w.background.width - margin_x
end

------------------------------------------------------------------------------
-- AUXILIARY FUNCTIONS
------------------------------------------------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

function ar_to_xy(xc, yc, angle, radius)
	local radians = (math.pi / 180) * angle

	local x = xc + radius * (math.sin(radians))
	local y = yc - radius * (math.cos(radians))

	return x, y
end

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

function text_width(cr, style, text)
	cairo_select_font_face(cr, style.fface, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, style.fsize)

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local width = t_extents.width - t_extents.x_bearing

	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)

	return width
end

function ellipsize_text(cr, style, text, max_width)
	-- If text fits within max width, return it as is
	if text_width(cr, style, text) <= max_width then
		return text
	end

	local out_text = text

	print(out_text)

	-- Truncate text and add ellipsis
	local ellipsis = "…"
	local ellipsis_width = text_width(cr, style, ellipsis)

	while text_width(cr, style, out_text) + ellipsis_width > max_width and #out_text > 0 do
		out_text = out_text:sub(1, -2)
	end

	return out_text..ellipsis
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
	text = string.upper(conky_parse(text))

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

	local text_w = t_extents.width + t_extents.x_bearing

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

------------------------------------------------------------------------------
-- WEATHER FUNCTIONS
------------------------------------------------------------------------------
function update_weather()
	local json = require("dkjson")

	-- Download weather data
	local url = 'api.openweathermap.org/data/2.5/weather?q='..weather.city..'&appid='..weather.app_id..'&units=metric'

	local handle = io.popen('curl -s "'..url..'"')
	local str = handle:read("*a")
	handle:close()

	-- Decode weather data from json
	local data, pos, err = json.decode(str, 1, nil)

	weather.location = (data ~= nil and data.name or '')
	weather.description = (data.weather[1] ~= nil and data.weather[1].main or '')
	weather.temperature = ((data.main ~= nil and data.main.temp ~= nil) and tostring(math.floor(tonumber(data.main.temp) + 0.5)) or '-')
	weather.feels_like = ((data.main ~= nil and data.main.feels_like ~= nil) and tostring(math.floor(tonumber(data.main.feels_like) + 0.5)) or '-')

	local icon = (data.weather[1] ~= nil and data.weather[1].icon or '')
	weather.icon = (icon ~= nil and string.gsub(conky_config, 'nothing.conf', 'icons/'..icon..'.png') or '')
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
	style.header.height = font_height(cr, style.header)
	style.weather.height = font_height(cr, style.weather)
	style.time.height = font_height(cr, style.time)

	-- Draw ring widgets
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

	-- Update weather if necessary
	local updates = tonumber(conky_parse("${updates}"))

	if updates ~= 0 and updates % weather.interval == 0 then
		update_weather()
	end

	-- Compute time widget values
	time.background.height = line_spacing * 4 + style.text.height * 3 + style.time.height + margin_y * 2

	-- Draw time widget background
	draw_background(cr, time.background)

	-- Draw weather icon
	local xs = time.background.x + margin_x
	local xe = time.background.x + time.background.width - margin_x
	local y = time.background.y + margin_y + style.weather.height + line_spacing * 0.5

	if weather.icon ~= '' then
		cairo_place_image(weather.icon, cr, xs, y - style.weather.height/2 - weather.icon_size/2 + weather.icon_dy, weather.icon_size, weather.icon_size, 1)
	end

	-- Draw time widget text
	draw_text(cr, style.weather, ALIGNL, xs + weather.icon_size + weather.icon_gap, y, weather.temperature..'°C')

	if weather.feels_like ~= '-' then
		y = y + line_spacing * 1.25 + style.text.height

		draw_text(cr, style.subtext, ALIGNL, xs, y, 'Feels like '..weather.feels_like..'°C')
	end

	y = time.background.y + margin_y + style.text.height

	draw_text(cr, style.text, ALIGNR, xe, y, '${time %a %d %b}')

	y = y + line_spacing + style.time.height

	draw_text(cr, style.time, ALIGNR, xe, y, '${time %R}')

	y = y + line_spacing * 2 + style.text.height

	draw_text(cr, style.text, ALIGNL, xs, y, weather.description)
	draw_text(cr, style.text, ALIGNR, xe, y, '${battery_percent BAT0}% BATT')

	y = y + line_spacing + style.text.height

	draw_text(cr, style.subtext, ALIGNL, xs, y, weather.location)
	draw_text(cr, style.subtext, ALIGNR, xe, y, '${battery_status BAT0}')

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
