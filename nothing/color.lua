------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'

local path = string.gsub(conky_config, 'color.conf', '?.lua')
package.path = package.path..';'..path
local lib = require 'common'

------------------------------------------------------------------------------
-- CONSTANTS (DO NOT DELETE)
------------------------------------------------------------------------------
local init_done = false

local accent_file = string.gsub(conky_config, 'color.conf', 'accent')
local accent_color = nil

------------------------------------------------------------------------------
-- WIDGET DATA
------------------------------------------------------------------------------
local widget = {
	button = {
		show = true,
		x = 0,
		y = 0,
		margin = 16,
		size = 64,
		icon = string.gsub(conky_config, 'color.conf', 'color/color.svg'),
		icon_size = 32,
		icon_color = lib.colors.default,
		is_down = false
	}
}

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Create cairo context
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Initialize
	if init_done == false then
		local f = io.open(accent_file, 'r')
		local str = nil

		if f ~= nil then
			str = f:read('*a')
			f:close()
		end

		accent_color = str and tonumber(str) or lib.colors.accent
		lib.set_xprop_accent(accent_color)

		init_done = true
	end

	-- Draw refresh button
	lib.draw_button(cr, widget.button)

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end

------------------------------------------------------------------------------
-- SHUTDOWN FUNCTION
------------------------------------------------------------------------------
function conky_shutdown()
	lib.remove_xprop_accent()

	io.output(accent_file)
	io.write(string.format('0x%x', accent_color))
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

	if widget.button.show and mouse_in_button(event, widget.button) then
		if event.type == 'button_down' then
			widget.button.is_down = true
		elseif event.type == 'button_up' and widget.button.is_down then
			local index = 0

			for i, color in ipairs(lib.accent_palette) do
				if color.color == accent_color then index = i end
			end

			if index == 0 then
				index = (event.mods.shift and #lib.accent_palette or 1)
			else
				if event.mods.shift then
					index = (index == 1 and #lib.accent_palette or index - 1)
				else
					index = (index == #lib.accent_palette and 1 or index + 1)
				end
			end

			accent_color = lib.accent_palette[index].color
			lib.set_xprop_accent(accent_color)

			widget.button.is_down = false
		end
	end
end
