------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'
require 'cairo_imlib2_helper'
require 'rsvg'

local path = string.gsub(conky_config, 'player.conf', '?.lua')
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

local background = {
	color = 0x28282c,
	border_radius = 36,
	padding_x = 40,
	padding_y = 40
}

local line_spacing = 22

------------------------------------------------------------------------------
-- WIDGET DATA
------------------------------------------------------------------------------
-- Named players (higher rank = preferred)
local named_players = {
	['Lollypop'] = { rank = 2 },
	['com.github.neithern.g4music'] = { rank = 1, alias = 'Gapless' },
	['Riff'] = { rank = 1, alias = 'Spotify' }
}

local widget = {
	align = ALIGNR,
	x = 0,
	y = 0,
	width = 900,
	player = nil,
	alias = nil,
	show_album = true,
	spacing_x = 32,
	heading = {},
	cover = {
		show = true,
		margin = 16,
		file = nil,
		icon_size = 80,
		icon_color = default_color,
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
		label = '',
		value = 50,
		value_max = 100,
		bg_color = default_color,
		bg_alpha = 0.05,
		fg_color = accent_color,
		fg_alpha = 1
	},
	metadata = {}
}

------------------------------------------------------------------------------
-- INITIALIZATION FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function init_fonts
---------------------------------------
function init_fonts(cr)
	fonts = {
		ring = {
			face = 'Ndot 57', size = 32, stroke = 0.5, color = accent_color
		},
		text = {
			face = 'Inter', size = 25, stroke = 0.6, color = default_color
		},
		caption = {
			face = 'Inter', size = 23, stroke = 0.4, color = caption_color
		},
		title = {
			face = 'Ndot77JPExtended', size = 44, stroke = 0.3, color = accent_color
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
function init_widget(cr)
	if widget.align == ALIGNR then
		widget.x = conky_window.width - widget.width
	elseif widget.align == ALIGNC then
		widget.x = (conky_window.width - widget.width)/2
	end

	widget.cover.size = fonts.title.height + fonts.text.height + fonts.caption.height * 2 + line_spacing * 4

	widget.ring.inner_radius = widget.cover.size/2 + widget.cover.margin
	widget.ring.outer_radius = widget.ring.inner_radius + widget.ring.mark_width + widget.ring.mark_thickness

	widget.ring.x = widget.x + background.padding_x + widget.ring.outer_radius
	widget.ring.y = widget.y + background.padding_y + widget.cover.size/2

	widget.height = widget.ring.outer_radius + widget.cover.size/2 + background.padding_y * 2

	widget.cover.x = widget.ring.x - widget.cover.size/2
	widget.cover.y = widget.ring.y - widget.cover.size/2

	widget.heading.x = widget.cover.x + widget.cover.size + widget.spacing_x * 1.5
	widget.heading.y = widget.cover.y

	widget.metadata.max_width = widget.x + widget.width - widget.heading.x - background.padding_x

	widget.metadata.title_x = widget.heading.x
	widget.metadata.title_y = widget.heading.y + fonts.caption.height + line_spacing * 1.5

	widget.metadata.subtitle_x = widget.metadata.title_x
	widget.metadata.subtitle_y = widget.metadata.title_y + fonts.title.height + line_spacing

	widget.metadata.status_x = widget.metadata.subtitle_x
	widget.metadata.status_y = widget.metadata.subtitle_y + fonts.text.height + line_spacing * 1.5

	widget.metadata.time_w = lib.text_width(cr, fonts.caption, '0:00')
	widget.metadata.stopped_w = lib.text_width(cr, fonts.caption, 'STOPPED')
end

---------------------------------------
-- Function update_player
---------------------------------------
function update_player()
	local lgi = require 'lgi'
	local Playerctl = lgi.Playerctl

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
	-- Get player cover art
	local url = widget.player:print_metadata_prop('mpris:artUrl')

	url = (widget.player.playback_status == 'STOPPED' and '' or url)

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

	if cover_file ~= widget.cover.file then
		widget.cover.file = cover_file
	end

	-- Get player metadata
	widget.metadata.title = widget.player.playback_status == 'STOPPED' and 'No Track' or (widget.player:get_title() or 'Track')

	local subtitle = widget.player.playback_status == 'STOPPED' and '---' or (widget.player:get_artist() or 'Unknown Artist')

	local album = widget.player:get_album()

	if widget.show_album and subtitle and subtitle ~= '---' and album and album ~= '' then
		widget.metadata.subtitle = subtitle..'  •  '..album
	else
		widget.metadata.subtitle = subtitle
	end

	-- Get player position/track length
	widget.metadata.pos = widget.player.position or 0

	local len_str = widget.player:print_metadata_prop('mpris:length')
	widget.metadata.len = len_str and tonumber(len_str) or 0
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_cover
---------------------------------------
function draw_cover(cr, cover)
	if (cover.show == false or cover.file == nil or cover.file == '') then
		-- Draw audio icon
		local icon = string.gsub(conky_config, 'player.conf', 'audio/audio.svg')

		local xi = cover.x + (cover.size - cover.icon_size)/2
		local yi = cover.y + (cover.size - cover.icon_size)/2

		draw_svg_icon(cr, icon, xi, yi, cover.icon_size, cover.icon_color, cover.icon_alpha)
	else
		-- Draw cover from file
		cairo_save(cr)

		cairo_arc(cr, cover.x + cover.size/2, cover.y + cover.size/2, cover.size/2, 0, math.pi*2)
		cairo_clip(cr)

		cairo_place_image(cover.file, cr, cover.x, cover.y, cover.size, cover.size, 1)

		cairo_restore(cr)
	end
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

	-- Initialize
	if init_done == false then
		init_fonts(cr)
		init_widget(cr)

		init_done = true
	end

	-- Update active player
	update_player()

	if widget.player then
		-- Draw background
		lib.draw_background(cr, widget, background)

		-- Update player metadata
		update_metadata()

		-- Draw ring
		widget.ring.value = (widget.metadata.len == 0 and 0 or widget.metadata.pos/widget.metadata.len * 100)
		lib.draw_ring(cr, widget.ring, fonts.ring)

		-- Draw cover art
		draw_cover(cr, widget.cover)

		-- Draw heading
		lib.draw_text(cr, fonts.caption, ALIGNL, widget.heading.x, widget.heading.y, widget.alias)

		-- Draw metadata
		lib.draw_text(cr, fonts.title, ALIGNL, widget.metadata.title_x, widget.metadata.title_y, widget.metadata.title, widget.metadata.max_width)

		lib.draw_text(cr, fonts.text, ALIGNL, widget.metadata.subtitle_x, widget.metadata.subtitle_y, widget.metadata.subtitle, widget.metadata.max_width)

		-- Draw status
		local x = widget.metadata.status_x

		lib.draw_text(cr, fonts.caption, ALIGNL, x, widget.metadata.status_y, widget.player.playback_status)

		x = x + widget.metadata.stopped_w + widget.spacing_x + widget.metadata.time_w

		lib.draw_text(cr, fonts.caption, ALIGNR, x, widget.metadata.status_y, lib.microsecs_to_string(widget.metadata.pos))

		local dx, _ = lib.draw_text(cr, fonts.caption, ALIGNL, x, widget.metadata.status_y, '  •  ')

		x = x + dx

		lib.draw_text(cr, fonts.caption, ALIGNL, x, widget.metadata.status_y, lib.microsecs_to_string(widget.metadata.len))
	end

	-- Destroy cairo context
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
