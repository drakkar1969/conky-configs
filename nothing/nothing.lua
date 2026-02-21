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
audio = {
	gap_x = 32,
	show_album = true,
	background = {
		x = 0,
		y = 935,
		width = 800
	},
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
