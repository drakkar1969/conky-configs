------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require('cairo')
require('cairo_xlib')
require('cairo_imlib2_helper')

package.path = package.path..';'..string.gsub(conky_config, 'player.conf', '?.lua')
local lib = require('common')

------------------------------------------------------------------------------
-- CONSTANTS (DO NOT DELETE)
------------------------------------------------------------------------------
local init_done = false

local accent_color = nil

------------------------------------------------------------------------------
-- WIDGET DATA
------------------------------------------------------------------------------
-- Named players (higher rank = preferred)
local named_players = {
	['Lollypop'] = { rank = 2 },
	['com.github.neithern.g4music'] = { rank = 1, alias = 'Gapless' },
	['Riff'] = { rank = 1, alias = 'Spotify' }
}

local icons = {
	audio = string.gsub(conky_config, 'player.conf', 'icons/audio.svg'),
	play = string.gsub(conky_config, 'player.conf', 'icons/audio-play.svg'),
	pause = string.gsub(conky_config, 'player.conf', 'icons/audio-pause.svg'),
	prev = string.gsub(conky_config, 'player.conf', 'icons/audio-prev.svg'),
	next = string.gsub(conky_config, 'player.conf', 'icons/audio-next.svg')
}

local widget = {
	halign = lib.halign.RIGHT,
	valign = lib.valign.TOP,
	width = 900,
	player = nil,
	alias = nil,
	show_album = true,
	spacing_x = 32,
	heading = {},
	cover = {
		show = true,
		margin = 16,
		url = nil,
		file = nil,
		icon = icons.audio,
		icon_size = 80,
		icon_color = lib.colors.default,
		icon_alpha = 0.2
	},
	ring = {
		start_angle = -200,
		end_angle = -40,
		step = 5,
		padding_x = 0,
		outer_radius = 40,
		mark_width = 8,
		mark_thickness = 4,
		mark_indent = 0,
		mark_outdent = 0,
		label = '',
		value = 50,
		value_max = 100,
		bg_color = lib.colors.default,
		bg_alpha = 0.1,
		fg_color = lib.colors.accent,
		fg_alpha = 1
	},
	metadata = {},
	controls = {
		spacing_x = 20,
		color = lib.colors.caption,
		alpha = 1,
		alpha_disabled = 0.5,
		play = {
			icon = '',
			size = 32,
			is_down = false
		},
		prev = {
			icon = icons.prev,
			size = 28,
			is_down = false
		},
		next = {
			icon = icons.next,
			size = 28,
			is_down = false
		}
	}
}

------------------------------------------------------------------------------
-- INITIALIZATION FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function init_widget
---------------------------------------
function init_widget(cr)
	widget.cover.size = lib.fonts.player.height + lib.fonts.title.height + lib.fonts.text.height + lib.fonts.caption.height + lib.line_spacing * 4

	widget.ring.inner_radius = widget.cover.size/2 + widget.cover.margin
	widget.ring.outer_radius = widget.ring.inner_radius + widget.ring.mark_width + widget.ring.mark_thickness

	widget.height = widget.ring.outer_radius + widget.cover.size/2 + lib.bg.padding_y * 2

	if widget.halign == lib.halign.LEFT then
		widget.x = 0
	elseif widget.halign == lib.halign.CENTER then
		widget.x = (conky_window.width - widget.width)/2
	else
		widget.x = conky_window.width - widget.width
	end

	if widget.valign == lib.valign.TOP then
		widget.y = 0
	elseif widget.valign == lib.valign.MIDDLE then
		widget.y = (conky_window.height - widget.height)/2
	else
		widget.y = conky_window.height - widget.height
	end

	widget.ring.x = widget.x + lib.bg.padding_x + widget.ring.outer_radius
	widget.ring.y = widget.y + lib.bg.padding_y + widget.cover.size/2

	widget.cover.x = widget.ring.x - widget.cover.size/2
	widget.cover.y = widget.ring.y - widget.cover.size/2

	widget.heading.x = widget.cover.x + widget.cover.size + widget.spacing_x * 1.5
	widget.heading.y = widget.cover.y + lib.line_spacing * 0.5

	widget.metadata.max_width = widget.x + widget.width - widget.heading.x - lib.bg.padding_x

	widget.metadata.title_x = widget.heading.x
	widget.metadata.title_y = widget.heading.y + lib.fonts.player.height + lib.line_spacing * 1.5

	widget.metadata.subtitle_x = widget.metadata.title_x
	widget.metadata.subtitle_y = widget.metadata.title_y + lib.fonts.title.height + lib.line_spacing

	widget.controls.prev.x = widget.metadata.subtitle_x
	widget.controls.prev.y = widget.metadata.subtitle_y + lib.fonts.text.height + lib.line_spacing * 1.5

	widget.controls.play.x = widget.controls.prev.x + widget.controls.prev.size + widget.controls.spacing_x
	widget.controls.play.y = widget.controls.prev.y - (widget.controls.play.size - widget.controls.prev.size)/2

	widget.controls.next.x = widget.controls.play.x + widget.controls.play.size + widget.controls.spacing_x
	widget.controls.next.y = widget.controls.prev.y

	local time_w = lib.text_width(cr, lib.fonts.caption, '0:00')
	local time_h = lib.font_height(cr, lib.fonts.caption)

	local div_w = lib.text_width(cr, lib.fonts.caption, '  •  ')

	widget.metadata.pos_x = widget.controls.next.x + widget.controls.next.size + widget.spacing_x * 3 + time_w
	widget.metadata.pos_y = widget.controls.next.y + (widget.controls.next.size - time_h)/2

	widget.metadata.len_x = widget.metadata.pos_x + div_w
	widget.metadata.len_y = widget.metadata.pos_y
end

---------------------------------------
-- Function update_player
---------------------------------------
function update_player()
	local Playerctl = require('lgi').Playerctl

	-- Find preferred player
	local rank = 0

	widget.player = nil
	widget.alias = nil

	for _, p in pairs(Playerctl.list_players()) do
		local named = named_players[p.instance]

		if named and named.rank > rank then
			widget.player = Playerctl.Player.new_from_name(p)
			widget.alias = named.alias or p.instance

			rank = named.rank
		end
	end
end

---------------------------------------
-- Function update_metadata
---------------------------------------
function update_metadata()
	-- Get cover art
	local url = widget.player:print_metadata_prop('mpris:artUrl')

	url = (widget.player.playback_status == 'STOPPED' and '' or url)

	if url ~= widget.cover.url then
		if url == nil or url == '' then
			widget.cover.file = nil
		elseif string.find(url, '^file://') then
			widget.cover.file = string.gsub(url, 'file://', '')
		elseif string.find(url, '^http') then
			local file = '/tmp/conky_nothing_cover'

			local handle = io.popen('curl -s "'..url..'"')
			local str = handle:read('*a')
			handle:close()

			io.output(file)
			io.write(str)
			io.output():close()

			widget.cover.file = file
		else
			widget.cover.file = nil
		end

		widget.cover.url = url
	end

	-- Get metadata
	widget.metadata.title = widget.player.playback_status == 'STOPPED' and 'No Track' or (widget.player:get_title() or 'Track')

	local subtitle = widget.player.playback_status == 'STOPPED' and '---' or (widget.player:get_artist() or 'Unknown Artist')

	local album = widget.player:get_album()

	if widget.show_album and subtitle and subtitle ~= '---' and album and album ~= '' then
		widget.metadata.subtitle = subtitle..'  •  '..album
	else
		widget.metadata.subtitle = subtitle
	end

	-- Get track length
	local len_str = widget.player:print_metadata_prop('mpris:length')
	widget.metadata.len = len_str and tonumber(len_str) or 0

	-- Get position
	widget.metadata.pos = widget.player.position or 0

	-- Get controls
	widget.controls.play.icon = (widget.player.playback_status == 'PLAYING' and icons.pause or icons.play)

	widget.controls.play.enabled = (widget.player.playback_status ~= 'STOPPED')
	widget.controls.prev.enabled = widget.player.can_go_previous
	widget.controls.next.enabled = widget.player.can_go_next
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_cover
---------------------------------------
function draw_cover(cr, cover)
	if cover.show == false or cover.file == nil then
		-- Draw audio icon
		local xi = cover.x + (cover.size - cover.icon_size)/2
		local yi = cover.y + (cover.size - cover.icon_size)/2

		lib.draw_svg_icon(cr, cover.icon, xi, yi, cover.icon_size, cover.icon_color, cover.icon_alpha)
	else
		-- Draw cover from file
		cairo_save(cr)

		cairo_arc(cr, cover.x + cover.size/2, cover.y + cover.size/2, cover.size/2, 0, math.pi*2)
		cairo_clip(cr)

		cairo_place_image(cover.file, cr, cover.x, cover.y, cover.size, cover.size, 1)

		cairo_restore(cr)
	end
end

---------------------------------------
-- Function draw_control
---------------------------------------
function draw_control(cr, ctrl)
	local alpha = (ctrl.enabled and widget.controls.alpha or widget.controls.alpha_disabled)

	lib.draw_svg_icon(cr, ctrl.icon, ctrl.x, ctrl.y, ctrl.size, widget.controls.color, alpha)
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	local updates = tonumber(conky_parse('${updates}'))

	if conky_window == nil then return end

	if updates < 2 then return end

	if conky_window == nil then return end

	-- Create cairo context
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Update accent color if necessary
	local xprop_color = lib.get_xprop_accent()

	if xprop_color ~= accent_color then
		accent_color = xprop_color

		lib.update_font_colors(accent_color)

		widget.ring.fg_color = accent_color
	end

	-- Initialize
	if init_done == false then
		lib.init_fonts(cr)
		init_widget(cr)

		init_done = true
	end

	-- Update active player
	update_player()

	if widget.player then
		-- Draw background
		lib.draw_background(cr, widget)

		-- Update player metadata
		update_metadata()

		-- Draw ring
		widget.ring.value = (widget.metadata.len == 0 and 0 or widget.metadata.pos/widget.metadata.len * 100)
		lib.draw_ring(cr, widget.ring)

		-- Draw cover art
		draw_cover(cr, widget.cover)

		-- Draw heading
		lib.draw_text(cr, lib.fonts.player, lib.halign.LEFT, widget.heading.x, widget.heading.y, widget.alias)

		-- Draw metadata
		lib.draw_text(cr, lib.fonts.title, lib.halign.LEFT, widget.metadata.title_x, widget.metadata.title_y, widget.metadata.title, widget.metadata.max_width)
		lib.draw_text(cr, lib.fonts.text, lib.halign.LEFT, widget.metadata.subtitle_x, widget.metadata.subtitle_y, widget.metadata.subtitle, widget.metadata.max_width)

		-- Draw controls
		draw_control(cr, widget.controls.prev)
		draw_control(cr, widget.controls.play)
		draw_control(cr, widget.controls.next)

		-- Draw status
		lib.draw_text(cr, lib.fonts.caption, lib.halign.RIGHT, widget.metadata.pos_x, widget.metadata.pos_y, lib.microsecs_to_string(widget.metadata.pos))
		lib.draw_text(cr, lib.fonts.caption, lib.halign.RIGHT, widget.metadata.len_x, widget.metadata.len_y, '  •  ')
		lib.draw_text(cr, lib.fonts.caption, lib.halign.LEFT, widget.metadata.len_x, widget.metadata.len_y, lib.microsecs_to_string(widget.metadata.len))
	end

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end

------------------------------------------------------------------------------
-- MOUSE EVENTS
------------------------------------------------------------------------------
function mouse_in_icon(event, icon)
	return event.x >= icon.x and event.x < icon.x + icon.size and event.y >= icon.y and event.y < icon.y + icon.size
end

function conky_mouse(event)
	if event.button ~= 'left' or event.mods.alt or event.mods.control or event.mods.super or event.mods.shift then return end

	if event.type == 'button_down' then
		if mouse_in_icon(event, widget.controls.prev) then
			widget.controls.prev.is_down = true
		elseif mouse_in_icon(event, widget.controls.play) then
			widget.controls.play.is_down = true
		elseif mouse_in_icon(event, widget.controls.next) then
			widget.controls.next.is_down = true
		end
	elseif event.type == 'button_up' then
		if mouse_in_icon(event, widget.controls.prev) and widget.controls.prev.is_down then
			if widget.player.can_go_previous then
				widget.player:previous()
			end
		elseif mouse_in_icon(event, widget.controls.play) and widget.controls.play.is_down then
			if widget.player.playback_status ~= 'STOPPED' then
				widget.player:play_pause()
			end
		elseif mouse_in_icon(event, widget.controls.next) and widget.controls.next.is_down then
			if widget.player.can_go_next then
				widget.player:next()
			end
		end

		widget.controls.prev.is_down = false
		widget.controls.play.is_down = false
		widget.controls.next.is_down = false
	end
end
