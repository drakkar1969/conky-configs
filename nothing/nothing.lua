------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'
require 'cairo_imlib2_helper'
require 'rsvg'

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

	if mouse_in_button(event, multi.buttons.color) then
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
