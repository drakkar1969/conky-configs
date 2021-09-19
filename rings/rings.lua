---------------------------------------
-- Constants
---------------------------------------
TEXTL = 0
TEXTR = 1

ALIGNL = 0
ALIGNC = 1
ALIGNR = 2

---------------------------------------
-- Ring variables
---------------------------------------
rings_table = {}

rings_attr = {
	bgc = 0x383c4a,
	bga = 0.2,
	fgc = 0x383c4a,
	fga = 0.6,
}

ring_x, ring_y = 0, 0

---------------------------------------
-- Text variables
---------------------------------------
text_table = {}

text_attr = {
	label = { font = 'Ubuntu', fgc = 0x21232b, fga = 1 },
	header = { font = 'Ubuntu', fgc = 0x383c4a, fga = 1 },
	time = { font = 'Ubuntu', fgc = 0x383c4a, fga = 1 }
}

text_gap = 12

header_font_size = 22
time_font_size = 38

---------------------------------------
-- Function add_rings
---------------------------------------
function add_rings(key, rings, vars)
	local r_outer = 0

	for i, v in pairs(vars) do
		local rng = {}

		rng.value = v.ring.value
		rng.max = v.ring.max

		rng.x, rng.y = rings.x, rings.y

		rng.ccw = rings.ccw

		rng.w = (type(rings.width) == 'table') and rings.width[i] or rings.width
		rng.sa = (type(rings.start_angle) == 'table') and rings.start_angle[i] or rings.start_angle
		rng.ea = (type(rings.end_angle) == 'table') and rings.end_angle[i] or rings.end_angle

		-- Calculate radius of indiviudal rings
		rng.r = rings.radius
		for j = 2, i do
			rng.r = rng.r + ((type(rings.width) == 'table') and ((rings.width[j] + rings.width[j-1])/2) or rings.width) + rings.gap
		end

		rng.attr = rings_attr

		rings_table[key..i] = rng

		r_outer = rng.r + rng.w/2

		-- Calculate label/value x,y coordinates
		local xt = rng.x + rng.r*math.sin(rings.text_angle*(2*math.pi/360))
		local xtl, xtv

		if rings.text_pos == TEXTL then
			xtl = xt - text_gap - rings.text_width
			xtv = xt - text_gap
		else
			xtl = xt + text_gap
			xtv = xt + text_gap + rings.text_width
		end

		local yt = rng.y - rng.r*math.cos(rings.text_angle*(2*math.pi/360))

		text_table[key..i] = {
			xl = xtl, xv = xtv,
			y = yt,
			label = v.text.label,
			value = v.text.value,
			align = ALIGNR, fs = rings.font_size,
			attr = text_attr.label
		}
	end

	return(r_outer)
end

---------------------------------------
-- Function add_header
---------------------------------------
function add_header(key, rings, ring_size, text, font_attr, font_size)
	-- Calculate header x,y coordinates
	local xt = rings.x + (ring_size + rings.header_gap)*math.sin(rings.header_angle*(2*math.pi/360))
	local yt = rings.y - (ring_size + rings.header_gap)*math.cos(rings.header_angle*(2*math.pi/360))

	text_table[key] = {
		xl = xt, xv = xt,
		y = yt,
		label = '',
		value = text,
		align = rings.header_align, fs = font_size,
		attr = font_attr
	}
end

---------------------------------------
-- CPU variables
---------------------------------------
-- CPU rings
cpu_rings = {
	x = ring_x + 180, y = ring_y + 135,
	radius = 60, width = 10,
	gap = 2,
	start_angle = 0, end_angle = 235,
	ccw = false,
	text_angle = 0, text_width = 68,
	font_size = 10.5, text_pos = TEXTL,
	header_angle = 242, header_gap = 26,
	header_align = ALIGNR
}

n_cpu = 4
cpu_vars = {}

for i = 1, n_cpu do
	cpu_vars[i] = {
		ring = { value = '${cpu cpu'..i..'}', max = 100 },
		text = { label = 'CPU '..i, value = '${cpu cpu'..i..'}%' }
	}
end

local rings_size = add_rings('cpu', cpu_rings, cpu_vars)

-- Core temperature text
text_table['temp'] = {
	xl = cpu_rings.x - 100, xv = cpu_rings.x,
	y = cpu_rings.y - rings_size - 20,
	label = 'CORE TEMP',
	value = '${acpitemp}°C',
	align = ALIGNL, fs = 15,
	attr = text_attr.label
}

-- Top CPU list
local top_y_spacing = 15

for i = 1, 3 do
	text_table['topcpu'..i] = {
		xl = cpu_rings.x - 151, xv = cpu_rings.x,
		y = cpu_rings.y + top_y_spacing*(i - 2),
		label = '${top name '..i..'}',
		value = '${top cpu '..i..'}%',
		align = ALIGNC, fs = 13.5,
		attr = text_attr.label
	}
end

-- Header
add_header('cpu_hdr', cpu_rings, rings_size, 'CPU', text_attr.header, header_font_size)

---------------------------------------
-- FS variables
---------------------------------------
-- FS rings
fs_rings = {
	x = ring_x + 370, y = ring_y + 115,
	radius = 27, width = 14,
	gap = 3,
	start_angle = 125, end_angle = 360,
	ccw = true,
	text_angle = 360, text_width = 175,
	font_size = 13.5, text_pos = TEXTR,
	header_angle = 105, header_gap = 0,
	header_align = ALIGNL
}

fs_disks = {
	{ name = 'home', path = '/home' },
	{ name = 'root', path = '/'},
	{ name = 'data', path = '/home/data'}
}

fs_vars = {}

for i, disk in pairs(fs_disks) do
	fs_vars[i] = {
		ring = { value = '${fs_used_perc '..disk.path..'}', max = 100 },
		text = { label = disk.name, value = '${fs_used '..disk.path..'} / ${fs_size '..disk.path..'}' }
	}
end

local rings_size = add_rings('fs', fs_rings, fs_vars)

-- Header
add_header('fs_hdr', fs_rings, rings_size, 'FILESYSTEM', text_attr.header, header_font_size)

---------------------------------------
-- MEM variables
---------------------------------------
-- MEM rings
mem_rings = {
	x = ring_x + 325, y = ring_y + 280,
	radius = 55, width = 17,
	gap = 3,
	start_angle = -180, end_angle = 55,
	ccw = false,
	text_angle = -180, text_width = 188,
	font_size = 14, text_pos = TEXTR,
	header_angle = 62, header_gap = 20,
	header_align = ALIGNL
}

mem_vars = {
	{
		ring = { value = '${swapperc}', max = 100 },
		text = { label = 'SWAP', value = '${swap} / ${swapmax}' }
	},
	{
		ring = { value = '${memperc}', max = 100 },
		text = { label = 'RAM', value = '${mem} / ${memmax}' }
	}
}

local rings_size = add_rings('mem', mem_rings, mem_vars)

-- Top MEM list
local top_y_spacing = 15

for i = 1, 3 do
	text_table['topmem'..i] = {
		xl = mem_rings.x - 15, xv = mem_rings.x + 160,
		y = mem_rings.y + 5 + top_y_spacing*(i - 2),
		label = '${top_mem name '..i..'}',
		value = '${top_mem mem '..i..'}%',
		align = ALIGNR, fs = 13.5,
		attr = text_attr.label
	}
end

-- Header
add_header('mem_hdr', mem_rings, rings_size, 'MEMORY', text_attr.header, header_font_size)

---------------------------------------
-- TIME variables
---------------------------------------
-- TIME rings
time_rings = {
	x = ring_x + 170, y = ring_y + 310,
	radius = 20, width = { 9, 11, 14 },
	gap = 3,
	start_angle = -55, end_angle = 180,
	ccw = true,
	text_angle = 180, text_width = 0,
	font_size = 15, text_pos = TEXTL,
	header_angle = -115, header_gap = -25,
	header_align = ALIGNR
}

time_vars = {
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
		text = { label = '', value = '${time %a %d-%m-%Y}' }
	}
}

local rings_size = add_rings('time', time_rings, time_vars)

-- Header
add_header('time_hdr', time_rings, rings_size, '${time %R}', text_attr.time, time_font_size)

---------------------------------------
-- BAT variables
---------------------------------------
-- BAT rings
bat_rings = {
	x = ring_x + 220, y = ring_y + 410,
	radius = 10, width = { 20, 12 },
	gap = 3,
	start_angle = { -180, -55 }, end_angle = { 180, 180 },
	ccw = true,
	text_angle = 180, text_width = 0,
	font_size = 13.5, text_pos = TEXTL,
	header_angle = -95, header_gap = 5,
	header_align = ALIGNR
}

bat_vars = {
	{
		ring = { value = '${goto 0}', max = 100 },
		text = { label = '', value = '' }
	},
	{
		ring = { value = '${battery_percent}', max = 100 },
		text = { label = '', value = '${battery}' }
	}
}

local rings_size = add_rings('bat', bat_rings, bat_vars)

-- Header
add_header('bat_hdr', bat_rings, rings_size, 'BATTERY', text_attr.header, header_font_size)

---------------------------------------
-- NET variables
---------------------------------------
-- NET rings
net_rings = {
	x = ring_x + 320, y = ring_y + 440,
	radius = 27, width = 16,
	gap = 3,
	start_angle = -180, end_angle = 55,
	ccw = false,
	text_angle = -180, text_width = 153,
	font_size = 13.5, text_pos = TEXTR,
	header_angle = 80, header_gap = 5,
	header_align = ALIGNL
}

-- Interface variables
wifi_interface = 'wlp3s0'
lan_interface = 'enp2s0'

net_interface = wifi_interface
net_conn = '${wireless_essid '..net_interface..'}'

-- Max values in KB/s
net_vars = {
	{
		ring = { value = '${upspeedf '..net_interface..'}', max = 1500 },
		text = { label = 'Up', value = '${upspeed '..net_interface..'}' }
	},
	{
		ring = { value = '${downspeedf '..net_interface..'}', max = 10000 },
		text = { label = 'Down', value = '${downspeed '..net_interface..'}' }
	}
}

local rings_size = add_rings('net', net_rings, net_vars)

-- Header
add_header('net_hdr', net_rings, rings_size, 'NETWORK', text_attr.header, header_font_size)

-- Extra NET text
local net_extra_text = {
	{ label = 'CONN', value = net_conn },
	{ label = 'LOCAL IP', value = '${addr '..net_interface..'}' }
}
local net_y_spacing = 20

for i, extra_text in pairs(net_extra_text) do
	text_table['netextra'..i] = {
		xl = net_rings.x + text_gap, xv = net_rings.x + text_gap + 92,
		y = net_rings.y + rings_size + 25 + net_y_spacing*(i - 1),
		label = extra_text.label,
		value = extra_text.value,
		align = ALIGNL, fs = 14,
		attr = text_attr.label
	}
end

---------------------------------------
-- LUA FUNCTIONS
---------------------------------------
require 'cairo'

---------------------------------------
-- Function rgb_to_r_g_b
---------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

---------------------------------------
-- Function draw_text
---------------------------------------
function draw_text(cr, pt)
	cairo_select_font_face(cr, pt.attr.font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr, pt.fs)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.fgc, pt.attr.fga))

	local t_extents = cairo_text_extents_t:create()
	tolua.takeownership(t_extents)
	cairo_text_extents(cr, pt.text, t_extents)

	local f_extents = cairo_font_extents_t:create()
	tolua.takeownership(f_extents)
	cairo_font_extents(cr, f_extents)

	local text_x = ((pt.align == ALIGNR) and (pt.x - t_extents.width - t_extents.x_bearing) or ((pt.align == ALIGNC) and (pt.x - t_extents.width*0.5 - t_extents.x_bearing*0.5) or pt.x) )
	local text_y = pt.y + f_extents.height/2 - f_extents.descent

	cairo_move_to(cr, text_x, text_y)
	cairo_show_text(cr, pt.text)
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_ring
---------------------------------------
function draw_ring(cr, pt)
	local str = conky_parse(pt.value)

	local value = tonumber(str)
	if value == nil then value = 0 end

	local pct = value/pt.max
	pct = (pct > 1 and 1 or pct)

	local angle_0 = pt.sa*(2*math.pi/360) - math.pi/2
	local angle_f = pt.ea*(2*math.pi/360) - math.pi/2
	local t_arc = pct*(angle_f - angle_0)

	-- Draw background ring
	cairo_arc(cr, pt.x, pt.y, pt.r, angle_0, angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.bgc, pt.attr.bga))
	cairo_set_line_width(cr, pt.w)
	cairo_stroke(cr)

	-- Draw indicator ring
	if pt.ccw == true then
		cairo_arc_negative(cr, pt.x, pt.y, pt.r, angle_f, angle_f - t_arc)
	else
		cairo_arc(cr, pt.x, pt.y, pt.r, angle_0, angle_0 + t_arc)
	end
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.fgc, pt.attr.fga))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_label_value
---------------------------------------
function draw_label_value(cr, pt)
	-- Draw label
	if pt.label ~= '' then
		draw_text(cr, { x = pt.xl, y = pt.y, text = conky_parse(pt.label), align = ALIGNL, fs = pt.fs, attr = pt.attr })
	end

	-- Draw value
	if pt.value ~= '' then
		draw_text(cr, { x = pt.xv, y = pt.y, text = conky_parse(pt.value), align = pt.align, fs = pt.fs, attr = pt.attr })
	end
end

---------------------------------------
-- Function conky_rings
---------------------------------------
function conky_rings()
	if conky_window == nil then return end

	local gw_up = tonumber(conky_parse('${if_up '..lan_interface..'}2${else}${if_up '..wifi_interface..'}1${else}0${endif}${endif}'))

	local check_interface = ((gw_up == 2) and lan_interface or ((gw_up == 1) and wifi_interface or 'none'))
	local check_conn = ((gw_up == 2) and 'LAN' or ((gw_up == 1) and '${wireless_essid '..check_interface..'}' or 'None'))

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	for id, ring in pairs(rings_table) do
		if id:find('net') then
			ring.value = ring.value:gsub(net_conn, check_conn)
			ring.value = ring.value:gsub(net_interface, check_interface)
		end
		draw_ring(cr, ring)
	end

	for id, text in pairs(text_table) do
		if id:find('net') then
			text.value = text.value:gsub(net_conn, check_conn)
			text.value = text.value:gsub(net_interface, check_interface)
		end
		draw_label_value(cr, text)
	end

	net_interface = check_interface
	net_conn = check_conn

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
