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
