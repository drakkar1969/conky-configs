------------------------------------------------------------------------------
-- CONSTANTS - DO NOT DELETE
------------------------------------------------------------------------------
-- Alignment of ring text
TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT = 0, 1, 2, 3
-- Text justification
ALIGNL, ALIGNC, ALIGNR = 0, 1, 2
-- Alignment of top lists
LTR, RTL = 0, 1

------------------------------------------------------------------------------
-- TABLE VARIABLES - DO NOT DELETE
------------------------------------------------------------------------------
widgets = {}
rings_table = {}
text_table = {}

------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
---------------------------------------
-- Light/dark colors
---------------------------------------
dark_colors = true

---------------------------------------
-- Font/color variables
---------------------------------------
main_color = dark_colors and 0x3d3846 or 0xdeddda
text_color = dark_colors and 0x241f31 or 0xc0bfbc

---------------------------------------
-- Ring colors
---------------------------------------
-- Ring background/foreground colors
rings_attr = {
	bg_color = main_color,
	bg_alpha = dark_colors and 0.15 or 0.3,
	fg_color = main_color,
	fg_alpha = dark_colors and 0.7 or 0.8,
}

---------------------------------------
-- Text font/colors
---------------------------------------
-- Text/header/extra/top font and colors
text_attr = {
	header = { font = 'Ubuntu', color = main_color, alpha = 1 },
	time = { font = 'Roboto', color = main_color, alpha = 1 },
	text = { font = 'Ubuntu', color = text_color, alpha = 1 },
	extra = { font = 'Ubuntu', color = text_color, alpha = 1 },
	top = { font = 'Ubuntu', color = text_color, alpha = 1 }
}

-- Horizontal gap between rings and text
text_gap = 14

---------------------------------------
-- CPU widget
---------------------------------------
-- Number of CPU cores = number of CPU rings
n_cpus = 12

-- Show global CPU percentage if true
single_cpu = true

-- CPU widget
widgets.cpu = {
	-- Header text, fontsize and offset from ring center
	header = { text = 'CPU', fontsize = 22, dx = -155, dy = 62 },
	rings = {
		-- Coordinates of ring center
		x = 172, y = 143,
		-- Radius of inner ring
		radius = 55,
		-- Width of rings / gap between rings
		width = 4, gap = 1,
	},
	text = {
		-- Text position. pos is one of TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT and determines position/orientation of rings
		pos = TOP_LEFT,
		-- Text width
		width = 68,
		-- Text fontsize
		fontsize = 10.5,
		-- Text fontsize if single_cpu is true
		fontsize_single= 20
	},
	-- Ring/text values (computed below based on number of cpus)
	values = {},
	-- Extra text fontsize, offset from ring center, width and space between lines
	extra_attr = { fontsize = 15.5, dx = -109, dy = -135, width = 109, spacing = 20 },
	-- Extra text values
	extra_values = {
		{ label = 'CORE TEMP', value = '${hwmon coretemp temp 1}°C' }
	},
	-- Top list text count, position, fontsize, offset from ring center, width and space between lines. pos is one of LTR, RTL
	top_attr = { count = 3, pos = RTL, fontsize = 13.5, dx = 18, dy = -2, width = 171, spacing = 16 },
	-- Top list values (computed below)
	top_values = {}
}

-- Compute CPU ring values
for i = 1, n_cpus do
	widgets.cpu.values[i] = {
		ring = '${cpu cpu'..i..'}',
		max = 100,
		label = 'CPU '..i,
		value = '${cpu cpu'..i..'}%'
	}
end

-- Compute CPU top list
for i = 1, widgets.cpu.top_attr.count do
	widgets.cpu.top_values[i] = {
		label = '${top name '..i..'}',
		value = '${top cpu '..i..'}%'
	}
end

---------------------------------------
-- FILESYSTEM widget
---------------------------------------
-- Disks table: number of name/path pairs = number of FILESYSTEM rings
disks = {
	{ name = 'boot', path = '/boot'},
	{ name = 'root', path = '/'},
	{ name = 'home', path = '/home' }
}

-- FILESYSTEM widget
widgets.fs = {
	-- Header text, fontsize and offset from ring center
	header = { text = 'FILESYSTEM', fontsize = 22, dx = 70, dy = 20 },
	rings = {
		-- Coordinates of ring center
		x = 370, y = 135,
		-- Radius of inner ring
		radius = 27,
		-- Width of rings / gap between rings
		width = 14, gap = 3,
	},
	text = {
		-- Text position. pos is one of TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT and determines position/orientation of rings
		pos = TOP_RIGHT,
		-- Text width
		width = 180,
		-- Text fontsize
		fontsize = 13.5,
	},
	-- Ring/text values (computed below based on disks table)
	values = {},
	-- Extra text fontsize, offset from ring center, width and space between lines
	extra_attr = { fontsize = 15.5, dx = -52, dy = -91, width = 77, spacing = 20 },
	-- Extra text values
	extra_values = {
		{ label = 'DISK IO', value = '${diskio}/s' }
	}
}

-- Compute FILESYSTEM ring values
for i, disk in pairs(disks) do
	widgets.fs.values[i] = {
		ring = '${fs_used_perc '..disk.path..'}',
		max = 100,
		label = disk.name,
		value = '${fs_used '..disk.path..'} / ${fs_size '..disk.path..'}'
	}
end

---------------------------------------
-- MEMORY widget
---------------------------------------
-- MEMORY widget
widgets.mem = {
	-- Header text, fontsize and offset from ring center
	header = { text = 'MEMORY', fontsize = 22, dx = 90, dy = -45 },
	rings = {
		-- Coordinates of ring center
		x = 325, y = 300,
		-- Radius of inner ring
		radius = 55,
		-- Width of rings / gap between rings
		width = 17, gap = 3,
	},
	text = {
		-- Text position. pos is one of TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT and determines position/orientation of rings
		pos = BOTTOM_RIGHT,
		-- Text width
		width = 188,
		-- Text fontsize
		fontsize = 14,
	},
	-- Ring/text values
	values = {
		{
			ring = '${swapperc}',
			max = 100,
			label = 'SWAP',
			value = '${swap} / ${swapmax}'
		},
		{
			ring = '${memperc}',
			max = 100,
			label = 'RAM',
			value = '${mem} / ${memmax}'
		}
	},
	-- Top list text count, position, fontsize, offset from ring center, width and space between lines. pos is one of LTR, RTL
	top_attr = { count = 3, pos = LTR, fontsize = 13.5, dx = -10, dy = 6, width = 195, spacing = 16 },
	-- Top list values (computed below)
	top_values = {}
}

-- Compute MEM top list
for i = 1, widgets.mem.top_attr.count do
	widgets.mem.top_values[i] = {
		label = '${top_mem name '..i..'}',
		value = '${top_mem mem_res '..i..'}'
	}
end

---------------------------------------
-- TIME widget
---------------------------------------
-- Date/time format
date_format = '%a %d-%m-%Y'
time_format = '%R'

-- TIME widget
widgets.time = {
	-- Header text, fontsize and offset from ring center
	header = { text = '${time '..time_format..'}', fontsize = 40, dx = -130, dy = 10 },
	rings = {
		-- Coordinates of ring center
		x = 170, y = 330,
		-- Radius of inner ring
		radius = 20,
		-- Width of rings (requires 3 values, inner ring to outer) / gap between rings
		width = { 9, 11, 14 }, gap = 3,
	},
	text = {
		-- Text position. pos is one of TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT and determines position/orientation of rings
		pos = BOTTOM_LEFT,
		-- Text width
		width = 0,
		-- Text fontsize
		fontsize = 15,
	},
	-- Ring/text values
	values = {
		{
			ring = '${time %S}',
			max = 60,
			label = '',
			value = ''
		},
		{
			ring = '${time %M}',
			max = 60,
			label = '',
			value = ''
		},
		{
			ring = '${time %H}',
			max = 24,
			label = '',
			value = '${time '..date_format..'}'
		}
	}
}

---------------------------------------
-- BATTERY widget
---------------------------------------
-- BATTERY widget
widgets.bat = {
	-- Header text, fontsize and offset from ring center
	header = { text = 'BATTERY', fontsize = 22, dx = -135, dy = 3 },
	rings = {
		-- Coordinates of ring center
		x = 220, y = 430,
		-- Radius of inner ring
		radius = 10,
		-- Width of rings (requires 2 values, inner ring to outer) / gap between rings
		width = { 20, 12 }, gap = 3,
	},
	text = {
		-- Text position. pos is one of TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT and determines position/orientation of rings
		pos = BOTTOM_LEFT,
		-- Text width
		width = 0,
		-- Text fontsize
		fontsize = 13.5,
	},
	-- Ring/text values
	values = {
		{
			-- Dummy value in inner ring (no foreground ring)
			ring = '0',
			max = 100,
			label = '',
			value = ''
		},
		{
			ring = '${battery_percent BAT0}',
			max = 100,
			label = '',
			value = '${battery BAT0}'
		}
	}
}

---------------------------------------
-- NETWORK widget
---------------------------------------
-- Network interface variables
wifi_interface = 'wlp0s20f3'
lan_interface = 'enp0s13f0u1'

-- Initial values for network interface and SSID (automatically adjusted in main function)
net_interface = wifi_interface
net_conn = '${wireless_essid '..net_interface..'}'

-- Max download/upload speeds in KB/s
net_max_down = 40000
net_max_up = 4000

-- NETWORK widget
widgets.net = {
	-- Header text, fontsize and offset from ring center
	header = { text = 'INTERNET', fontsize = 22, dx = 60, dy = -10 },
	rings = {
		-- Coordinates of ring center
		x = 320, y = 460,
		-- Radius of inner ring
		radius = 27,
		-- Width of rings / gap between rings
		width = 16, gap = 3,
	},
	text = {
		-- Text position. pos is one of TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT and determines position/orientation of rings
		pos = BOTTOM_RIGHT,
		-- Text width
		width = 153,
		-- Text fontsize
		fontsize = 13.5,
	},
	-- Ring/text values
	values = {
		{
			ring = '${upspeedf '..net_interface..'}',
			max = net_max_up,
			label = 'Up',
			value = '${upspeed '..net_interface..'}'
		},
		{
			ring = '${downspeedf '..net_interface..'}',
			max = net_max_down,
			label = 'Down',
			value = '${downspeed '..net_interface..'}'
		}
	},
	-- Extra text fontsize, offset from ring center, width and space between lines
	extra_attr = { fontsize = 15, dx = text_gap, dy = 80, width = 110, spacing = 20 },
	-- Extra text values
	extra_values = {
		{ label = 'NETWORK', value = net_conn },
		{ label = 'LOCAL IP', value = '${addr '..net_interface..'}' }
	}
}

------------------------------------------------------------------------------
-- BUILD RING/TEXT TABLES
------------------------------------------------------------------------------
for id, widget in pairs(widgets) do
	-- Add widget header to text table
	text_table[id..'header'] = {
		text = widget.header.text,
		attr = id == 'time' and text_attr.time or text_attr.header,
		fontsize = widget.header.fontsize,
		x = widget.rings.x + widget.header.dx,
		y = widget.rings.y + widget.header.dy,
		align = ALIGNL
	}

	for i, value in pairs(widget.values) do
		local ring_r, ring_w, ring_sa, ring_ea, ring_ccw

		-- Calculate radius of individual ring
		ring_r = widget.rings.radius

		for j = 2, i do
			ring_r = ring_r + ((type(widget.rings.width) == 'table') and ((widget.rings.width[j] + widget.rings.width[j-1])/2) or widget.rings.width) + widget.rings.gap
		end

		-- Calculate width of individual ring
		ring_w = (type(widget.rings.width) == 'table') and widget.rings.width[i] or widget.rings.width

		-- Calculate start/end angle and direction of ring
		if widget.text.pos == TOP_LEFT then
			ring_sa, ring_ea, ring_ccw = 0, 235, false
		elseif widget.text.pos == TOP_RIGHT then
			ring_sa, ring_ea, ring_ccw = 125, 360, true
		elseif widget.text.pos == BOTTOM_LEFT then
			ring_sa, ring_ea, ring_ccw = -55, 180, true
		elseif widget.text.pos == BOTTOM_RIGHT then
			ring_sa, ring_ea, ring_ccw = -180, 55, false
		end

		-- Correct start/end angle of ring for battery inner ring (is 360°)
		if id == 'bat' and i == 1 then
			ring_sa, ring_ea = 0, 360
		end

		-- Add ring to rings table
		rings_table[id..i] = {
			value = value.ring,
			max = value.max,
			x = widget.rings.x, y = widget.rings.y,
			r = ring_r,
			w = ring_w,
			sa = ring_sa, ea = ring_ea,
			ccw = ring_ccw,
			attr = rings_attr
		}

		if id == 'cpu' and single_cpu then
			if i == 1 then
				-- Calculate text x,y coordinates and alignment
				local ring_rs, text_x, text_y, text_align

				if widget.text.pos == TOP_LEFT or widget.text.pos == BOTTOM_LEFT then
					text_x = widget.rings.x - text_gap
					text_align = ALIGNR
				else
					text_x = widget.rings.x + text_gap
					text_align = ALIGNL
				end

				if widget.text.pos == TOP_LEFT or widget.text.pos == TOP_RIGHT then
					text_y = widget.rings.y - widget.rings.radius - (n_cpus - 1)*(widget.rings.width + widget.rings.gap)/2
				else
					text_y = widget.rings.y + widget.rings.radius + (n_cpus - 1)*(widget.rings.width + widget.rings.gap)/2
				end

				-- Add value text to table
				text_table[id..i..'value'] = {
					text = '${cpu cpu0}%',
					attr = text_attr.text,
					fontsize = widget.text.fontsize_single,
					x = text_x, y = text_y,
					align = text_align
				}
			end
		else
			-- Calculate text x,y coordinates and alignment
			local label_x, value_x, text_y

			if widget.text.pos == TOP_LEFT or widget.text.pos == BOTTOM_LEFT then
				label_x = widget.rings.x - text_gap - widget.text.width
				value_x = widget.rings.x - text_gap
			else
				label_x = widget.rings.x + text_gap
				value_x = widget.rings.x + text_gap + widget.text.width
			end

			if widget.text.pos == TOP_LEFT or widget.text.pos == TOP_RIGHT then
				text_y = widget.rings.y - ring_r
			else
				text_y = widget.rings.y + ring_r
			end

			local value_align = ALIGNR

			if value.label == "" and (widget.text.pos == TOP_RIGHT or widget.text.pos == BOTTOM_RIGHT) then
				value_align = ALIGNL
			end

			-- Add label text to table
			text_table[id..i..'label'] = {
				text = value.label,
				attr = text_attr.text,
				fontsize = widget.text.fontsize,
				x = label_x, y = text_y,
				align = ALIGNL
			}

			-- Add value text to table
			text_table[id..i..'value'] = {
				text = value.value,
				attr = text_attr.text,
				fontsize = widget.text.fontsize,
				x = value_x, y = text_y,
				align = value_align
			}
		end
	end

	if widget.extra_values ~= nil then
		for i, value in pairs(widget.extra_values) do
			-- Add extra text label to table
			text_table[id..'extralabel'..i] = {
				text = value.label,
				attr = text_attr.extra,
				fontsize = widget.extra_attr.fontsize,
				x = widget.rings.x + widget.extra_attr.dx,
				y = widget.rings.y + widget.extra_attr.dy + (i-1)*widget.extra_attr.spacing,
				align = ALIGNL
			}

			-- Add extra text value to table
			text_table[id..'extravalue'..i] = {
				text = value.value,
				attr = text_attr.extra,
				fontsize = widget.extra_attr.fontsize,
				x = widget.rings.x + widget.extra_attr.dx + widget.extra_attr.width,
				y = widget.rings.y + widget.extra_attr.dy + (i-1)*widget.extra_attr.spacing,
				align = ALIGNL
			}
		end
	end

	if widget.top_values ~= nil then
		-- Calculate initial coordinates of top list text
		local xi = widget.rings.x + widget.top_attr.dx - (widget.top_attr.pos == RTL and widget.top_attr.width or 0)
		local yi = widget.rings.y + widget.top_attr.dy - (widget.top_attr.count/2 - 0.5)*widget.top_attr.spacing

		for i, value in pairs(widget.top_values) do
			-- Add top list label to table
			text_table[id..'toplabel'..i] = {
				text = value.label,
				attr = text_attr.top,
				fontsize = widget.top_attr.fontsize,
				x = xi,
				y = yi + (i-1)*widget.top_attr.spacing,
				align = ALIGNL
			}

			-- Add top list value to table
			text_table[id..'topvalue'..i] = {
				text = value.value,
				attr = text_attr.top,
				fontsize = widget.top_attr.fontsize,
				x = xi + widget.top_attr.width,
				y = yi + (i-1)*widget.top_attr.spacing,
				align = ALIGNR
			}
		end
	end
end

------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'

------------------------------------------------------------------------------
-- AUXILIARY FUNCTIONS
------------------------------------------------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_ring
---------------------------------------
function draw_ring(cr, pt)
	-- Calculate ring value as percentage
	local str = conky_parse(pt.value)

	local value = tonumber(str)
	if value == nil then value = 0 end

	local pct = value/pt.max
	pct = (pct > 1 and 1 or pct)

	-- Calculate ring angles
	local angle_0 = pt.sa*(2*math.pi/360) - math.pi/2
	local angle_f = pt.ea*(2*math.pi/360) - math.pi/2
	local t_arc = pct*(angle_f - angle_0)

	-- Draw background ring
	cairo_arc(cr, pt.x, pt.y, pt.r, angle_0, angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.bg_color, pt.attr.bg_alpha))
	cairo_set_line_width(cr, pt.w)
	cairo_stroke(cr)

	-- Draw indicator ring
	if pt.ccw == true then
		cairo_arc_negative(cr, pt.x, pt.y, pt.r, angle_f, angle_f - t_arc)
	else
		cairo_arc(cr, pt.x, pt.y, pt.r, angle_0, angle_0 + t_arc)
	end
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.fg_color, pt.attr.fg_alpha))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr, pt)
	-- Set text font/color
	cairo_select_font_face(cr, pt.attr.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, pt.fontsize)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.color, pt.attr.alpha))

	local text = conky_parse(pt.text)

	-- Calculate text and font extents
	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, text, t_extents)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	-- Justify text
	local text_x = ((pt.align == ALIGNR) and (pt.x - t_extents.width - t_extents.x_bearing) or ((pt.align == ALIGNC) and (pt.x - t_extents.width*0.5 - t_extents.x_bearing*0.5) or pt.x) )
	local text_y = pt.y + f_extents.height/2 - f_extents.descent

	-- Draw text
	cairo_move_to(cr, text_x, text_y)
	cairo_show_text(cr, text)
	cairo_stroke(cr)

	-- Destroy structures
	tolua.releaseownership(f_extents)
	cairo_font_extents_t:destroy(f_extents)

	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Check network interface status
	local gw_up = tonumber(conky_parse('${if_up '..lan_interface..'}2${else}${if_up '..wifi_interface..'}1${else}0${endif}${endif}'))

	local check_interface = ((gw_up == 2) and lan_interface or ((gw_up == 1) and wifi_interface or 'None'))
	local check_conn = ((gw_up == 2) and 'Wired' or ((gw_up == 1) and '${wireless_essid '..check_interface..'}' or 'No Network'))

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Draw rings (update network interface)
	for id, ring in pairs(rings_table) do
		if id:find('net') then
			ring.value = ring.value:gsub(net_conn, check_conn)
			ring.value = ring.value:gsub(net_interface, check_interface)
		end

		draw_ring(cr, ring)
	end

	-- Draw text (update network interface)
	for id, text in pairs(text_table) do
		if id:find('net') then
			text.text = text.text:gsub(net_conn, check_conn)
			text.text = text.text:gsub(net_interface, check_interface)
		end

		draw_text(cr, text)
	end

	-- Update network variables
	net_interface = check_interface
	net_conn = check_conn

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
