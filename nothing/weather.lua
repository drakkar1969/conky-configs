------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'
require 'cairo_imlib2_helper'
require 'rsvg'

local json = require('dkjson')

local path = string.gsub(conky_config, 'weather.conf', '?.lua')
package.path = package.path..';'..path
local lib = require 'common'

------------------------------------------------------------------------------
-- CONSTANTS (DO NOT DELETE)
------------------------------------------------------------------------------
local init_done = false

local ALIGNL, ALIGNC, ALIGNR = 0, 1, 2

local fonts = {}

local default_color = 0xffffff
local caption_color = 0xaaaaaa
local accent_color = 0xffc057

local line_spacing = 22

------------------------------------------------------------------------------
-- WIDGET DATA
------------------------------------------------------------------------------
local weather = {
	app_id = 'b1b61a08efe33de67901d98c4f5711f5',
	city = 'Mogilany,PL',
	check_interval = 900
}

local widget = {
	horizontal = true,
	align = ALIGNR,
	x = 0,
	y = 0,
	width = 700,
	spacing_x = 32,
	spacing_y = 130,
	time = {
		date = '${time %a %d %b}',
		time = '${time %R}'
	},
	battery = {
		charge = '${battery_percent BAT0}% BATT',
		status = '${battery_status BAT0}'
	},
	weather = {
		icon = '',
		icon_size = 64,
		location = '',
		description = '',
		temperature = '',
		feels_like = ''
	},
	button = {
		show = true,
		size = 56,
		icon = string.gsub(conky_config, 'weather.conf', 'weather/refresh.svg'),
		icon_size = 32,
		color = default_color,
		is_down = false
	}
}

------------------------------------------------------------------------------
-- INITIALIZATION FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function init_fonts
---------------------------------------
function init_fonts(cr)
	fonts = {
		text = {
			face = 'Inter', size = 25, stroke = 0.6, color = default_color
		},
		caption = {
			face = 'Inter', size = 23, stroke = 0.4, color = caption_color
		},
		time = {
			face = 'Ndot77JPExtended', size = 84, stroke = 0.6, color = accent_color
		},
		weather = {
			face = 'Ndot77JPExtended', size = 52, stroke = 0.3, color = accent_color
		}
	}

	-- Calculate font heights
	for k, font in pairs(fonts) do
		font.height = lib.font_height(cr, font)
	end
end

---------------------------------------
-- Function init_widget
---------------------------------------
function init_widget()
	if widget.align == ALIGNR then
		widget.x = conky_window.width - widget.width
	elseif widget.align == ALIGNC then
		widget.x = (conky_window.width - widget.width)/2
	end

	if widget.horizontal then 
		widget.height = line_spacing * 4 + fonts.text.height * 2 + fonts.caption.height + fonts.time.height + lib.bg.padding_y * 2
	else
		widget.height = line_spacing * 8.5 + fonts.text.height * 3 + fonts.caption.height * 3 + fonts.time.height + fonts.weather.height + widget.spacing_y + lib.bg.padding_y * 2
	end

	widget.time.date_x = widget.x + widget.width - lib.bg.padding_x
	widget.time.date_y = widget.y + lib.bg.padding_y

	widget.time.time_x = widget.time.date_x
	widget.time.time_y = widget.time.date_y + fonts.text.height + line_spacing

	widget.battery.charge_x = widget.time.time_x
	widget.battery.charge_y = widget.time.time_y + fonts.time.height + line_spacing * 2

	widget.battery.status_x = widget.battery.charge_x
	widget.battery.status_y = widget.battery.charge_y + fonts.text.height + line_spacing

	widget.weather.temperature_x = widget.x + lib.bg.padding_x + widget.weather.icon_size + widget.spacing_x
	if widget.horizontal then
		widget.weather.temperature_y = widget.y + lib.bg.padding_y + line_spacing * 0.5
	else
		widget.weather.temperature_y = widget.battery.status_y + fonts.caption.height + widget.spacing_y
	end

	widget.weather.icon_x = widget.x + lib.bg.padding_x
	widget.weather.icon_y = widget.weather.temperature_y + (fonts.weather.height - widget.weather.icon_size)/2

	widget.button.y = widget.weather.icon_y

	widget.weather.feels_like_x = widget.weather.icon_x
	widget.weather.feels_like_y = widget.weather.temperature_y + fonts.weather.height + line_spacing * 1.25

	widget.weather.description_x = widget.weather.feels_like_x
	if widget.horizontal then
		widget.weather.description_y = widget.battery.charge_y
	else
		widget.weather.description_y = widget.weather.feels_like_y + fonts.caption.height + line_spacing * 2.25
	end

	widget.weather.location_x = widget.weather.description_x
	if widget.horizontal then
		widget.weather.location_y = widget.battery.status_y
	else
		widget.weather.location_y = widget.weather.description_y + fonts.text.height + line_spacing
	end
end

---------------------------------------
-- Function update_weather
---------------------------------------
function update_weather()
	print('NOTHING: Weather data updated at '..os.date('%Y-%m-%d %H:%M:%S'))

	-- Download weather data
	local url = 'api.openweathermap.org/data/2.5/weather?q='..weather.city..'&appid='..weather.app_id..'&units=metric'

	local handle = io.popen('curl -s "'..url..'"')
	local str = handle:read('*a')
	handle:close()

	-- Decode weather data from json
	local data, pos, err = json.decode(str, 1, nil)

	widget.weather.location = (data and data.name or '')
	widget.weather.description = ((data and data.weather[1]) and data.weather[1].main or '')
	widget.weather.temperature = ((data and data.main and data.main.temp) and tostring(math.floor(tonumber(data.main.temp) + 0.5)) or '-')
	widget.weather.feels_like = ((data and data.main and data.main.feels_like) and tostring(math.floor(tonumber(data.main.feels_like) + 0.5)) or '-')

	local icon = ((data and data.weather[1]) and data.weather[1].icon)
	widget.weather.icon = (icon and string.gsub(conky_config, 'weather.conf', 'weather/'..icon..'.png') or '')
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	local updates = tonumber(conky_parse('${updates}'))

	if conky_window == nil then return end

	if updates < 2 then return end

	-- Create cairo context
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Initialize
	if init_done == false then
		init_fonts(cr)
		init_widget()

		update_weather()

		init_done = true
	end

	-- Update weather if necessary
	if updates ~= 0 and updates % weather.check_interval == 0 then
		update_weather()
	end

	-- Draw background
	lib.draw_background(cr, widget)

	-- Draw date/time
	lib.draw_text(cr, fonts.text, ALIGNR, widget.time.date_x, widget.time.date_y, widget.time.date)
	lib.draw_text(cr, fonts.time, ALIGNR, widget.time.time_x, widget.time.time_y, widget.time.time)

	-- Draw battery text
	lib.draw_text(cr, fonts.text, ALIGNR, widget.battery.charge_x, widget.battery.charge_y, widget.battery.charge)
	lib.draw_text(cr, fonts.caption, ALIGNR, widget.battery.status_x, widget.battery.status_y, widget.battery.status)

	-- Draw weather icon
	if widget.weather.icon ~= '' then
		cairo_place_image(widget.weather.icon, cr, widget.weather.icon_x, widget.weather.icon_y, widget.weather.icon_size, widget.weather.icon_size, 1)
	end

	-- Draw weather temperature text
	local dx, _ = lib.draw_text(cr, fonts.weather, ALIGNL, widget.weather.temperature_x, widget.weather.temperature_y, widget.weather.temperature..'°C')
	lib.draw_text(cr, fonts.caption, ALIGNL, widget.weather.feels_like_x, widget.weather.feels_like_y, 'Feels like '..widget.weather.feels_like..'°C')

	-- Draw refresh button
	if widget.button.show then
		widget.button.x = widget.weather.temperature_x + dx + widget.spacing_x
		lib.draw_button(cr, widget.button)
	end

	-- Draw weather status text
	lib.draw_text(cr, fonts.text, ALIGNL, widget.weather.description_x, widget.weather.description_y, widget.weather.description)
	lib.draw_text(cr, fonts.caption, ALIGNL, widget.weather.location_x, widget.weather.location_y, widget.weather.location)

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
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

	if widget.button.show and mouse_in_button(event, widget.button) and event.mods.shift == false then
		if event.type == 'button_down' then
			widget.button.is_down = true
		elseif event.type == 'button_up' and widget.button.is_down then
			update_weather()

			widget.button.is_down = false
		end
	end
end
