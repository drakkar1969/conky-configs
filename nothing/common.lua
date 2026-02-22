local lib = {}

------------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------------
---------------------------------------
-- Color variables
---------------------------------------
lib.accent_palette = {
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

lib.colors = {
	default = 0xffffff,
	caption = 0xaaaaaa,
	heading = 0xaaaaaa,
	accent = lib.accent_palette[4].color
}

---------------------------------------
-- Fonts
---------------------------------------
lib.fonts = {
	heading = {
		face = 'Ndot 55', size = 36, stroke = 0, color = lib.colors.heading
	},
	text = {
		face = 'Inter', size = 25, stroke = 0.6, color = lib.colors.default
	},
	caption = {
		face = 'Inter', size = 23, stroke = 0.4, color = lib.colors.caption
	},
	ring = {
		face = 'Ndot 57', size = 32, stroke = 0.5, color = lib.colors.accent
	},
	player = {
		face = 'Ndot 55', size = 32, stroke = 0, color = lib.colors.heading
	},
	title = {
		face = 'Ndot77JPExtended', size = 44, stroke = 0.3, color = lib.colors.accent
	},
	time = {
		face = 'Ndot77JPExtended', size = 84, stroke = 0.3, color = lib.colors.accent
	},
	weather = {
		face = 'Ndot77JPExtended', size = 52, stroke = 0.3, color = lib.colors.accent
	}
}

---------------------------------------
-- Other variables
---------------------------------------
lib.halign = {
	LEFT = 0,
	CENTER = 1,
	RIGHT = 2
}

lib.valign = {
	TOP = 0,
	MIDDLE = 1,
	BOTTOM = 2
}

lib.bg = {
	color = 0x28282c,
	border_radius = 36,
	padding_x = 40,
	padding_y = 40
}

lib.line_spacing = 22

------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function rgb_to_r_g_b
---------------------------------------
function lib.rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

---------------------------------------
-- Function font_height
---------------------------------------
function lib.font_height(cr, font)
	cairo_select_font_face(cr, font.face, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font.size)

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
function lib.text_width(cr, font, text)
	cairo_select_font_face(cr, font.face, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font.size)

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local width = t_extents.x_advance

	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)

	return width
end

---------------------------------------
-- Function draw_background
---------------------------------------
function lib.draw_background(cr, widget)
	local conv = math.pi / 180

	cairo_new_sub_path(cr)
	cairo_arc(cr, widget.x + widget.width - lib.bg.border_radius, widget.y + lib.bg.border_radius, lib.bg.border_radius, -90 * conv, 0)
	cairo_arc(cr, widget.x + widget.width - lib.bg.border_radius, widget.y + widget.height - lib.bg.border_radius, lib.bg.border_radius, 0, 90 * conv)
	cairo_arc(cr, widget.x + lib.bg.border_radius, widget.y + widget.height - lib.bg.border_radius, lib.bg.border_radius, 90 * conv, 180 * conv);
	cairo_arc(cr, widget.x + lib.bg.border_radius, widget.y + lib.bg.border_radius, lib.bg.border_radius, 180 * conv, 270 * conv);
	cairo_close_path(cr)

	cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(lib.bg.color, 1))
	cairo_fill(cr)
end

---------------------------------------
-- Function ellipsize
---------------------------------------
function lib.ellipsize(cr, font, text, max_width)
	-- If text fits within max width, return it as is
	if lib.text_width(cr, font, text) <= max_width then
		return text
	end

	local out_text = text

	-- Truncate text and add ellipsis
	local ellipsis = '…'
	local ellipsis_width = lib.text_width(cr, font, ellipsis)

	while lib.text_width(cr, font, out_text) + ellipsis_width > max_width and #out_text > 0 do
		local chars = {}

		for c in string.gmatch(out_text, '[%z\1-\127\194-\244][\128-\191]*') do
			table.insert(chars, c)
		end

		out_text = table.concat(chars, '', 1, #chars - 2)
	end

	return out_text..ellipsis
end

---------------------------------------
-- Function accented_upper
---------------------------------------
function lib.accented_upper(text)
	-- Accented character map
	local accented_map = {
		['á'] = 'Á', ['é'] = 'É', ['í'] = 'Í', ['ó'] = 'Ó', ['ú'] = 'Ú',
		['à'] = 'À', ['è'] = 'È', ['ì'] = 'Ì', ['ò'] = 'Ò', ['ù'] = 'Ù',
		['â'] = 'Â', ['ê'] = 'Ê', ['î'] = 'Î', ['ô'] = 'Ô', ['û'] = 'Û',
		['ä'] = 'Ä', ['ë'] = 'Ë', ['ï'] = 'Ï', ['ö'] = 'Ö', ['ü'] = 'Ü',
		['ã'] = 'Ã', ['õ'] = 'Õ', ['ñ'] = 'Ñ', ['ç'] = 'Ç'
	}

	text = string.upper(text)

	return (string.gsub(text, '[%z\1-\127\194-\244][\128-\191]*', function(char)
		return accented_map[char] or char
	end))
end

---------------------------------------
-- Function draw_text
---------------------------------------
function lib.draw_text(cr, font, align, x, y, text, max_width)
	text = lib.accented_upper(conky_parse(text))

	-- Ellipsize text if necessary
	if max_width then
		text = lib.ellipsize(cr, font, text, max_width)
	end

	-- Set font/color
	cairo_select_font_face(cr, font.face, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font.size)
	cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(font.color, 1))

	-- Calculate text position
	local text_w = lib.text_width(cr, font, text)

	local text_x = ((align == lib.halign.RIGHT) and (x - text_w) or ((align == lib.halign.CENTER) and (x - text_w * 0.5) or x))

	-- Draw text
	cairo_move_to(cr, text_x, y + font.height)
	cairo_text_path(cr, text)
	cairo_set_line_width(cr, font.stroke)
	cairo_stroke_preserve(cr)
	cairo_fill(cr)

	return text_w, font.height
end

---------------------------------------
-- Function ar_to_xy
---------------------------------------
function lib.ar_to_xy(xc, yc, angle, radius)
	local radians = (math.pi / 180) * angle

	local x = xc + radius * (math.sin(radians))
	local y = yc - radius * (math.cos(radians))

	return x, y
end

---------------------------------------
-- Function draw_ring
---------------------------------------
function lib.draw_ring(cr, ring, font)
	local str = conky_parse(ring.value)

	-- Calculate ring value
	local value = tonumber(str)
	if value == nil then value = 0 end

	local pct = value/ring.value_max
	pct = (pct > 1 and 1 or pct)

	local value_angle = pct * (ring.end_angle - ring.start_angle) + ring.start_angle

	-- Draw ring marks
	for angle = ring.start_angle, ring.end_angle, ring.step do
		local xs, ys = lib.ar_to_xy(ring.x, ring.y, angle, ring.outer_radius)

		cairo_move_to(cr, xs, ys)

		local xe, ye = lib.ar_to_xy(ring.x, ring.y, angle, ring.inner_radius)

		cairo_line_to(cr, xe, ye)

		if angle <= value_angle then
			cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(ring.fg_color, ring.fg_alpha))
		else
			cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(ring.bg_color, ring.bg_alpha))
		end
		cairo_set_line_width(cr, ring.mark_thickness)
		cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
		cairo_stroke(cr)
	end

	-- Draw ring text
	lib.draw_text(cr, font, lib.halign.CENTER, ring.x, ring.y - font.height, ring.label)
end

---------------------------------------
-- Function microsecs_to_string
---------------------------------------
function lib.microsecs_to_string(microsecs)
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

---------------------------------------
-- Function draw_svg_icon
---------------------------------------
function lib.draw_svg_icon(cr, file, x, y, size, color, alpha)
	cairo_save(cr)

	-- Load SVG image from file
	local handle = rsvg_create_handle_from_file(file)

	-- Position and size SVG image
	local rect = RsvgRectangle:create()
	tolua.takeownership(rect)

	rect:set(x, y, size, size)

	-- Render SVG image on temporary canvas
	cairo_push_group(cr)
	rsvg_handle_render_document(handle, cr, rect)

	-- Re-color and draw SVG image
	local pattern = cairo_pop_group(cr)

	cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(color, alpha))
	cairo_mask(cr, pattern)
	cairo_pattern_destroy(pattern)

	-- Destroy objects
	tolua.releaseownership(rect)
	RsvgRectangle:destroy(rect)

	rsvg_destroy_handle(handle)

	cairo_restore(cr)
end

---------------------------------------
-- Function draw_button
---------------------------------------
function lib.draw_button(cr, btn)
	cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(lib.bg.color, 1))
	cairo_arc(cr, btn.x + btn.size/2, btn.y + btn.size/2, btn.size/2, 0, math.pi * 2)
	cairo_fill(cr)

	local x = btn.x + (btn.size - btn.icon_size)/2
	local y = btn.y + (btn.size - btn.icon_size)/2

	lib.draw_svg_icon(cr, btn.icon, x, y, btn.icon_size, btn.icon_color, 1)
end

return lib
