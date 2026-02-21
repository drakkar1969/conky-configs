local lib = {}

local ALIGNL, ALIGNC, ALIGNR = 0, 1, 2

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
function lib.draw_background(cr, widget, bg)
	local conv = math.pi / 180

	cairo_new_sub_path(cr)
	cairo_arc(cr, widget.x + widget.width - bg.border_radius, widget.y + bg.border_radius, bg.border_radius, -90 * conv, 0)
	cairo_arc(cr, widget.x + widget.width - bg.border_radius, widget.y + widget.height - bg.border_radius, bg.border_radius, 0, 90 * conv)
	cairo_arc(cr, widget.x + bg.border_radius, widget.y + widget.height - bg.border_radius, bg.border_radius, 90 * conv, 180 * conv);
	cairo_arc(cr, widget.x + bg.border_radius, widget.y + bg.border_radius, bg.border_radius, 180 * conv, 270 * conv);
	cairo_close_path(cr)

	cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(bg.color, 1))
	cairo_fill(cr)
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
	-- if max_width then
	-- 	text = ellipsize_text(cr, style, text, max_width)
	-- end

	-- Set font/color
	cairo_select_font_face(cr, font.face, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, font.size)
	cairo_set_source_rgba(cr, lib.rgb_to_r_g_b(font.color, 1))

	-- Calculate text position
	local text_w = lib.text_width(cr, font, text)

	local text_x = ((align == ALIGNR) and (x - text_w) or ((align == ALIGNC) and (x - text_w * 0.5) or x))

	-- Draw text
	cairo_move_to(cr, text_x, y + font.height)
	cairo_text_path(cr, text)
	cairo_set_line_width(cr, font.stroke)
	cairo_stroke_preserve(cr)
	cairo_fill(cr)

	return text_w, font.height
end

return lib
