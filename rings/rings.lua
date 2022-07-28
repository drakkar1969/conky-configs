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
rings = {}
extras = {}
tops = { cpu = {}, mem = {} }
top_count = {}
vars = { cpu = {}, fs = {}, mem = {}, time = {}, bat = {}, net = {} }
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
	text = { font = 'Ubuntu', color = text_color, alpha = 1 },
	header = { font = 'Ubuntu', color = main_color, alpha = 1 },
	extra = { font = 'Ubuntu', color = text_color, alpha = 1 },
	top = { font = 'Ubuntu', color = text_color, alpha = 1 }
}

-- Horizontal gap between rings and text
text_gap = 14

---------------------------------------
-- CPU rings
---------------------------------------
-- Number of CPU cores = number of CPU rings
n_cpus = 8

-- Number of top CPU processes
top_count.cpu = 3

-- Show global CPU percentage if true
single_cpu = true

-- CPU rings
rings.cpu = {
	-- Coordinates of ring center
	x = 182, y = 133,
	-- Radius of inner ring
	radius = 57,
	-- Width of rings / gap between rings
	width = 5, gap = 1,
	-- Ring text position, width and fontsize. pos is one of TOP_LEFT, TOP_RIGHT,
	-- BOTTOM_LEFT, BOTTOM_RIGHT and determines position/orientation of rings
	text = { pos = TOP_LEFT, width = 68, fontsize = 10.5, fontsize_single= 20 },
	-- Header text, fontsize and offset from ring center
	header = { text = 'CPU', fontsize = 22, dx = -145, dy = 60 },
	-- Extra text fontsize, offset from ring center, width and space between lines
	extra = { fontsize = 15.5, dx = -109, dy = -125, width = 109, spacing = 20 },
	-- Top list text position, fontsize, offset from ring center, width and space
	-- between lines. pos is one of LTR, RTL
	top = { pos = RTL, fontsize = 13.5, dx = 18, dy = -2, width = 171, spacing = 16 }
}

---------------------------------------
-- FILESYSTEM rings
---------------------------------------
-- Disks table: number of name/path pairs = number of FILESYSTEM rings
disks = {
	{ name = 'home', path = '/home' },
	{ name = 'root', path = '/'},
	{ name = 'boot', path = '/boot'}
}

-- FILESYSTEM rings
rings.fs = {
	x = 370, y = 115,
	radius = 27,
	width = 14, gap = 3,
	text = { pos = TOP_RIGHT, width = 180, fontsize = 13.5 },
	header = { text = 'FILESYSTEM', fontsize = 22, dx = 70, dy = 20 },
	extra = { fontsize = 15.5, dx = -52, dy = -91, width = 77, spacing = 20 }
}

---------------------------------------
-- MEMORY rings
---------------------------------------
-- Number of top MEMORY processes
top_count.mem = 3

-- MEMORY rings
rings.mem = {
	x = 325, y = 280,
	radius = 55,
	width = 17, gap = 3,
	text = { pos = BOTTOM_RIGHT, width = 188, fontsize = 14 },
	header = { text = 'MEMORY', fontsize = 22, dx = 90, dy = -45 },
	top = { pos = LTR, fontsize = 13.5, dx = -10, dy = 6, width = 195, spacing = 16 }
}

---------------------------------------
-- TIME rings
---------------------------------------
-- Date/time format
date_format = '%a %d-%m-%Y'
time_format = '%R'

-- TIME rings
rings.time = {
	x = 170, y = 310,
	radius = 20,
	-- Width requires 3 values: inner to outer ring from left to right
	width = { 9, 11, 14 }, gap = 3,
	text = { pos = BOTTOM_LEFT, width = 0, fontsize = 15 },
	header = { text = '${time '..time_format..'}', fontsize = 36, dx = -115, dy = 12 }
}

---------------------------------------
-- BATTTERY rings
---------------------------------------
rings.bat = {
	x = 220, y = 410,
	radius = 10,
	-- Width requires 2 values: inner to outer ring from left to right
	width = { 20, 12 }, gap = 3,
	text = { pos = BOTTOM_LEFT, width = 0, fontsize = 13.5 },
	header = { text = 'BATTERY', fontsize = 22, dx = -135, dy = 3 }
}

---------------------------------------
-- NETWORK rings
---------------------------------------
-- Network interface variables
wifi_interface = 'wlo1'
lan_interface = 'enp2s0'

-- Initial value for network interface (automatically adjusted in main function)
net_interface = wifi_interface

-- Max download/upload speeds in KB/s
net_max_down = 2700
net_max_up = 270

-- NETWORK rings
rings.net = {
	x = 320, y = 440,
	radius = 27,
	width = 16, gap = 3,
	text = { pos = BOTTOM_RIGHT, width = 153, fontsize = 13.5 },
	header = { text = 'NETWORK', fontsize = 22, dx = 60, dy = -20 },
	extra = { fontsize = 15, dx = text_gap, dy = 80, width = 110, spacing = 20 }
}

------------------------------------------------------------------------------
-- INITIALIZE RING/TEXT CONKY VARIABLES
------------------------------------------------------------------------------
for i = 1, n_cpus do
	vars.cpu[i] = {
		ring = { value = '${cpu cpu'..i..'}', max = 100 },
		text = { label = 'CPU '..i, value = '${cpu cpu'..i..'}%' }
	}
end

for i, disk in pairs(disks) do
	vars.fs[i] = {
		ring = { value = '${fs_used_perc '..disk.path..'}', max = 100 },
		text = { label = disk.name, value = '${fs_used '..disk.path..'} / ${fs_size '..disk.path..'}' }
	}
end

vars.mem = {
	{
		ring = { value = '${swapperc}', max = 100 },
		text = { label = 'SWAP', value = '${swap} / ${swapmax}' }
	},
	{
		ring = { value = '${memperc}', max = 100 },
		text = { label = 'RAM', value = '${mem} / ${memmax}' }
	}
}

vars.time = {
	{
		ring = { value = '${time %S}', max = 60 },
		text = { label = '', value = '' }
	},
	{
		ring = { value = '${time %M}', max = 60 },
		text = { label = '', value = '' }
	},
	{
		ring = { value = '${time %H}', max = 24 },
		text = { label = '', value = '${time '..date_format..'}' }
	}
}

vars.bat = {
	{
		-- Dummy value in inner ring (no foreground ring)
		ring = { value = '0', max = 100 },
		text = { label = '', value = '' }
	},
	{
		ring = { value = '${battery_percent}', max = 100 },
		text = { label = '', value = '${battery}' }
	}
}

vars.net = {
	{
		ring = { value = '${upspeedf '..net_interface..'}', max = net_max_up },
		text = { label = 'Up', value = '${upspeed '..net_interface..'}' }
	},
	{
		ring = { value = '${downspeedf '..net_interface..'}', max = net_max_down },
		text = { label = 'Down', value = '${downspeed '..net_interface..'}' }
	}
}

extras.cpu = {
	{ label = 'CORE TEMP', value = '${acpitemp}°C' }
}

extras.fs = {
	{ label = 'DISK IO', value = '${diskio}/s' }
}

net_conn = '${wireless_essid '..net_interface..'}'

extras.net = {
	{ label = 'LOCAL IP', value = '${addr '..net_interface..'}' },
	{ label = 'NETWORK', value = net_conn }
}

for i = 1, top_count.cpu do
	tops.cpu[i] = { label = '${top name '..i..'}', value = '${top cpu '..i..'}%' }
end

for i = 1, top_count.mem do
	tops.mem[i] = { label = '${top_mem name '..i..'}', value = '${top_mem mem_res '..i..'}' }
end

------------------------------------------------------------------------------
-- BUILD RING/TEXT TABLES
------------------------------------------------------------------------------
for id, table in pairs(vars) do
	for i, var in pairs(table) do
		local ring_r, ring_w, ring_sa, ring_ea, ring_ccw

		-- Calculate radius of individual ring
		ring_r = rings[id].radius
		for j = 2, i do
			ring_r = ring_r + ((type(rings[id].width) == 'table') and ((rings[id].width[j] + rings[id].width[j-1])/2) or rings[id].width) + rings[id].gap
		end

		-- Calculate width of individual ring
		ring_w = (type(rings[id].width) == 'table') and rings[id].width[i] or rings[id].width

		-- Calculate start/end angle and direction of ring
		if rings[id].text.pos == TOP_LEFT then
			ring_sa, ring_ea, ring_ccw = 0, 235, false
		elseif rings[id].text.pos == TOP_RIGHT then
			ring_sa, ring_ea, ring_ccw = 125, 360, true
		elseif rings[id].text.pos == BOTTOM_LEFT then
			ring_sa, ring_ea, ring_ccw = -55, 180, true
		elseif rings[id].text.pos == BOTTOM_RIGHT then
			ring_sa, ring_ea, ring_ccw = -180, 55, false
		end

		if id == 'bat' and i == 1 then
			ring_sa, ring_ea = 0, 360
		end

		-- Add ring to table
		rings_table[id..i] = {
			value = var.ring.value,
			max = var.ring.max,
			x = rings[id].x, y = rings[id].y,
			r = ring_r,
			w = ring_w,
			sa = ring_sa, ea = ring_ea,
			ccw = ring_ccw,
			bgc = rings_attr.bg_color,
			bga = rings_attr.bg_alpha,
			fgc = rings_attr.fg_color,
			fga = rings_attr.fg_alpha
		}

		if single_cpu and id == 'cpu' then
			if i == 1 then
				-- Calculate text x,y coordinates and alignment
				local ring_rs, text_x, text_y, text_align

				if rings[id].text.pos == TOP_LEFT or rings[id].text.pos == BOTTOM_LEFT then
					text_x = rings[id].x - text_gap
					text_align = ALIGNR
				else
					text_x = rings[id].x + text_gap
					text_align = ALIGNL
				end

				if rings[id].text.pos == TOP_LEFT or rings[id].text.pos == TOP_RIGHT then
					text_y = rings[id].y - rings[id].radius - (n_cpus - 1)*(rings[id].width + rings[id].gap)/2
				else
					text_y = rings[id].y + rings[id].radius + (n_cpus - 1)*(rings[id].width + rings[id].gap)/2
				end

				-- Add value text to table
				text_table[id..i..'value'] = {
					text = '${cpu cpu0}%',
					font = text_attr.text.font,
					fs = rings[id].text.fontsize_single,
					color = text_attr.text.color,
					alpha = text_attr.text.alpha,
					x = text_x, y = text_y,
					align = text_align
				}
			end
		else
			-- Calculate text x,y coordinates and alignment
			local label_x, value_x, text_y

			if rings[id].text.pos == TOP_LEFT or rings[id].text.pos == BOTTOM_LEFT then
				label_x = rings[id].x - text_gap - rings[id].text.width
				value_x = rings[id].x - text_gap
			else
				label_x = rings[id].x + text_gap
				value_x = rings[id].x + text_gap + rings[id].text.width
			end

			if rings[id].text.pos == TOP_LEFT or rings[id].text.pos == TOP_RIGHT then
				text_y = rings[id].y - ring_r
			else
				text_y = rings[id].y + ring_r
			end

			local value_align = ALIGNR

			if var.text.label == "" and (rings[id].text.pos == TOP_RIGHT or rings[id].text.pos == BOTTOM_RIGHT) then
				value_align = ALIGNL
			end

			-- Add label text to table
			text_table[id..i..'label'] = {
				text = var.text.label,
				font = text_attr.text.font,
				fs = rings[id].text.fontsize,
				color = text_attr.text.color,
				alpha = text_attr.text.alpha,
				x = label_x, y = text_y,
				align = ALIGNL
			}

			-- Add value text to table
			text_table[id..i..'value'] = {
				text = var.text.value,
				font = text_attr.text.font,
				fs = rings[id].text.fontsize,
				color = text_attr.text.color,
				alpha = text_attr.text.alpha,
				x = value_x, y = text_y,
				align = value_align
			}
		end

		-- Add ring header to table
		if i == 1 then
			text_table[id..'header'] = {
				text = rings[id].header.text,
				font = text_attr.header.font,
				fs = rings[id].header.fontsize,
				color = text_attr.header.color,
				alpha = text_attr.header.alpha,
				x = rings[id].x + rings[id].header.dx,
				y = rings[id].y + rings[id].header.dy,
				align = ALIGNL
			}
		end
	end
end

for id, table in pairs(extras) do
	for i, extra in pairs(table) do
		-- Add extra text label to table
		text_table[id..'extralabel'..i] = {
			text = extra.label,
			font = text_attr.extra.font,
			fs = rings[id].extra.fontsize,
			color = text_attr.extra.color,
			alpha = text_attr.extra.alpha,
			x = rings[id].x + rings[id].extra.dx,
			y = rings[id].y + rings[id].extra.dy + (i-1)*rings[id].extra.spacing,
			align = ALIGNL
		}

		-- Add extra text value to table
		text_table[id..'extravalue'..i] = {
			text = extra.value,
			font = text_attr.extra.font,
			fs = rings[id].extra.fontsize,
			color = text_attr.extra.color,
			alpha = text_attr.extra.alpha,
			x = rings[id].x + rings[id].extra.dx + rings[id].extra.width,
			y = rings[id].y + rings[id].extra.dy + (i-1)*rings[id].extra.spacing,
			align = ALIGNL
		}
	end
end

for id, temp in pairs(tops) do
	-- Calculate initial coordinates of top list text
	local xi = rings[id].x + rings[id].top.dx - (rings[id].top.pos == RTL and rings[id].top.width or 0)
	local yi = rings[id].y + rings[id].top.dy - (top_count[id]/2 - 0.5)*rings[id].top.spacing

	for i, top in pairs(temp) do
		-- Add top list label to table
		text_table[id..'toplabel'..i] = {
			text = top.label,
			font = text_attr.top.font,
			fs = rings[id].top.fontsize,
			color = text_attr.top.color,
			alpha = text_attr.top.alpha,
			x = xi,
			y = yi + (i-1)*rings[id].top.spacing,
			align = ALIGNL
		}

		-- Add top list value to table
		text_table[id..'topvalue'..i] = {
			text = top.value,
			font = text_attr.top.font,
			fs = rings[id].top.fontsize,
			color = text_attr.top.color,
			alpha = text_attr.top.alpha,
			x = xi + rings[id].top.width,
			y = yi + (i-1)*rings[id].top.spacing,
			align = ALIGNR
		}
	end
end

-- ring_x, ring_y = 0, 0

------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'

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
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.bgc, pt.bga))
	cairo_set_line_width(cr, pt.w)
	cairo_stroke(cr)

	-- Draw indicator ring
	if pt.ccw == true then
		cairo_arc_negative(cr, pt.x, pt.y, pt.r, angle_f, angle_f - t_arc)
	else
		cairo_arc(cr, pt.x, pt.y, pt.r, angle_0, angle_0 + t_arc)
	end
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.fgc, pt.fga))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr, pt)
	-- Set text font/color
	cairo_select_font_face(cr, pt.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, pt.fs)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))

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
