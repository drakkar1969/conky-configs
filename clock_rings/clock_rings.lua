------------------------------------------------------------------------------
-- LUA MODULES
------------------------------------------------------------------------------
require 'cairo'
require 'cairo_xlib'

------------------------------------------------------------------------------
-- CONSTANTS - DO NOT DELETE
------------------------------------------------------------------------------
-- Text justification
local ALIGNL, ALIGNC, ALIGNR = 0, 1, 2
local ALIGNT, ALIGNM, ALIGNB = 0, 1, 2

------------------------------------------------------------------------------
-- TABLE VARIABLES - DO NOT DELETE
------------------------------------------------------------------------------
local rings_table = {}
local text_table = {}
local graphs_table = {}
local lines_table = {}

------------------------------------------------------------------------------
-- USER CONFIGURATION
------------------------------------------------------------------------------
---------------------------------------
-- Light/dark colors
---------------------------------------
local dark_colors = false

---------------------------------------
-- Font/color variables
---------------------------------------
local main_color = dark_colors and 0x3d3846 or 0xdeddda
local text_color = dark_colors and 0x241f31 or 0xc0bfbc
local main_font = 'Adwaita Sans'
local time_font = 'Roboto'

---------------------------------------
-- Ring colors
---------------------------------------
local rings_attr = {
	bg_color = main_color,
	bg_alpha = dark_colors and 0.15 or 0.3,
	fg_color = main_color,
	fg_alpha = dark_colors and 0.7 or 0.8,
	dummy_alpha = 0.15
}

---------------------------------------
-- Other colors
---------------------------------------
local other_attr = {
	clock = { color = 0x0461be, alpha = 1 },
	graph = { color = main_color, alpha = dark_colors and 0.7 or 0.8 },
	dotline = { color = main_color, alpha = 0.6 }
}

---------------------------------------
-- Text fonts/colors
---------------------------------------
local text_attr = {
	disk = { font = main_font, fontsize = 25, color = text_color, alpha = 0.9 },
	label = { font = main_font, fontsize = 32, color = main_color, alpha = 0.7 },
	value = { font = main_font, fontsize = 30, color = main_color, alpha = 1 },
	time = { font = time_font, fontsize = 80, color = main_color, alpha = 1 },
	date = { font = main_font, fontsize = 42, color = text_color, alpha = 0.9 },
	top = { font = main_font, fontsize = 23, color = text_color, alpha = 1 }
}

---------------------------------------
-- Rings
---------------------------------------
local rings = {
	-- Coordinates of center of ring and radius (of inner seconds ring)
	x = 520, y = 460, radius = 140,
	-- Seconds ring: width and gap from CPU/memory/temp rings
	sec = { width = 8, gap = 10 },
	-- CPU rings: no. of CPU cores, width and gap of rings
	cpu = { n = 12, width = 3, gap = 2 },
	-- Disks: width of rings, gap from CPU/memory/temp rings, vertical offset of
	-- text from ring center, horiz gap between disk text at top and disks rings
	disk = { width = 12, gap = 10, text_gap_x = 40, text_gap_y = 36 },
	-- Dummy rings: width and gap on left/right of each ring
	dummy = { width = 4, gap = 60 },
	-- Graph: width/height of graph, width/gap of individual bars, log_scale
	graph = { width = 800, height = 60, bar_w = 2, bar_gap = 0, log_scale = true },
	-- Main horizontal line: width and gap from disk rings
	line = { width = 4, gap = 16 },
	-- Temperature text: gap between text and disks ring along angle, width of text
	temp = { text_gap_r = 50, text_angle = 57, text_w = 315 },
	-- Date text: vertical offset from main line
	date = { text_gap_y = 40 },
	-- NET text: vertical offset from main line, width of text
	net = { text_gap_y = 30, text_w = 240 },
	-- Top CPU/MEM lists: no. of items, gap between title text and disks ring along 
	-- angle, width of text, width of line, vertical gap between line and text,
	-- vertical distance between text lines
	topcpu = { n = 4, text_gap_r = 60, text_angle = 145, text_w = 380, line_w = 2, line_gap_y = 28, text_space_y = 34 },
	topmem = { n = 4, text_gap_r = 256, text_angle = 234, text_w = 380, line_w = 2, line_gap_y = 28, text_space_y = 34 }
}

-- Clock hands: width and gap between individual hands and inner seconds ring
local clock_hands = {
	hrs_width = 8,
	hrs_gap = 36,
	min_width = 4,
	min_gap = 10,
	sec_width = 2,
	sec_gap = 6,
	show_seconds = true
}

-- Name and path of two disks to display in disk rings/text
local disks = {
	{ name = 'root', path = '/' },
	{ name = 'home', path = '/home'}
}

-- Network interface variables
local wifi_interface = 'wlp0s20f3'
local lan_interface = 'enp0s13f0u1'

-- Initial value for network interface (automatically adjusted in main function)
local net_interface = wifi_interface

-- Max download speed in KB/s
local net_max_down = 2800

------------------------------------------------------------------------------
-- BUILD VARIABLE TABLES
------------------------------------------------------------------------------
---------------------------------------
-- Seconds ring
---------------------------------------
rings_table['sec'] = {
	name = 'time', arg = '%S', max = 60,
	bg_color = rings_attr.bg_color, bg_alpha = rings_attr.bg_alpha,
	fg_color = rings_attr.fg_color, fg_alpha = rings_attr.fg_alpha,
	x = rings.x, y = rings.y,
	radius = rings.radius,
	width = rings.sec.width,
	start_angle = 0, end_angle = 360
}

rings_ext_r = rings.radius + rings.sec.width/2

---------------------------------------
-- CPU rings
---------------------------------------
for i = 1, rings.cpu.n do
	rings_table['cpu'..i] = {
		name = 'cpu', arg = 'cpu'..i, max = 100,
		bg_color = rings_attr.bg_color, bg_alpha = rings_attr.bg_alpha,
		fg_color = rings_attr.fg_color, fg_alpha = rings_attr.fg_alpha,
		x = rings.x, y = rings.y,
		radius = rings_ext_r + rings.sec.gap + rings.cpu.width/2 + (i - 1)*(rings.cpu.width + rings.cpu.gap),
		width = rings.cpu.width,
		start_angle = 91, end_angle = 209
	}
end

cpu_rings_w = rings.cpu.n*rings.cpu.width + (rings.cpu.n - 1)*rings.cpu.gap

---------------------------------------
-- Memory/Temperature rings
---------------------------------------

rings_table['mem'] = {
	name = 'memperc', arg = '', max = 100,
	bg_color = rings_attr.bg_color, bg_alpha = rings_attr.bg_alpha,
	fg_color = rings_attr.fg_color, fg_alpha = rings_attr.fg_alpha,
	x = rings.x, y = rings.y,
	radius = rings_ext_r + rings.sec.gap + cpu_rings_w/2,
	width = cpu_rings_w,
	start_angle = 212, end_angle = 329
}

rings_table['temp'] = {
	name = 'hwmon', arg = 'coretemp temp 1', max = 100,
	bg_color = rings_attr.bg_color, bg_alpha = rings_attr.bg_alpha,
	fg_color = rings_attr.fg_color, fg_alpha = rings_attr.fg_alpha,
	x = rings.x, y = rings.y,
	radius = rings_ext_r + rings.sec.gap + cpu_rings_w/2,
	width = cpu_rings_w,
	start_angle = -28, end_angle = 88
}

rings_ext_r = rings_ext_r + rings.sec.gap + cpu_rings_w

---------------------------------------
-- Disk rings
---------------------------------------
for i, disk in pairs(disks) do
	rings_table['disk'..i] = {
		name = 'fs_used_perc', arg = disk.path, max = 100,
		bg_color = rings_attr.bg_color, bg_alpha = rings_attr.bg_alpha,
		fg_color = rings_attr.fg_color, fg_alpha = rings_attr.fg_alpha,
		x = rings.x, y = rings.y,
		radius = rings_ext_r + rings.disk.gap + rings.disk.width/2,
		width = rings.disk.width,
		start_angle = (i == 1 and -120 or 2), end_angle = (i == 1 and -2 or 120)
	}
end

rings_ext_r = rings_ext_r + rings.disk.gap + rings.disk.width

---------------------------------------
-- Dummy rings
---------------------------------------
for i = 1, 2 do
	rings_table['dummy'..i] = {
		name = 'cpu', arg = '', max = 100,
		bg_color = rings_attr.bg_color, bg_alpha = rings_attr.dummy_alpha,
		fg_color = rings_attr.fg_color, fg_alpha = 0,
		x = rings.x + (i-1)*(rings.graph.width + 2*rings.dummy.gap + rings.dummy.width), y = rings.y,
		radius = rings_ext_r + rings.dummy.gap + rings.dummy.width/2,
		width = rings.dummy.width,
		start_angle = 73, end_angle = 107
	}
end

---------------------------------------
-- Clock hands
---------------------------------------
clock_hands.x = rings.x
clock_hands.y = rings.y
clock_hands.radius = rings.radius - rings.sec.width/2

---------------------------------------
-- Graph
---------------------------------------
graphs_table['net'] = {
	name = 'downspeedf',
	arg = net_interface,
	max = net_max_down,
	color = other_attr.graph.color,
	alpha = other_attr.graph.alpha,
	x = rings.x + rings_ext_r + 2*rings.dummy.gap + rings.dummy.width, y = rings.y - rings.line.width/2,
	w = rings.graph.width, h = rings.graph.height,
	bar_w = rings.graph.bar_w, bar_gap = rings.graph.bar_gap,
	data = {},
	log_scale = rings.graph.log_scale
}

---------------------------------------
-- Time text
---------------------------------------
text_table['time'] = {
	text = '${time %H %M}',
	font = text_attr.time.font,
	fs = text_attr.time.fontsize,
	color = text_attr.time.color,
	alpha = text_attr.time.alpha,
	x = rings.x,
	y = rings.y,
	align_x = ALIGNC,
	align_y = ALIGNM
}

---------------------------------------
-- Disk text
---------------------------------------
for i, disk in pairs(disks) do
	text_table['disk'..i] = {
		text = disk.name..'   ${fs_used '..disk.path..'}/${fs_size '..disk.path..'}',
		font = text_attr.disk.font,
		fs = text_attr.disk.fontsize,
		color = text_attr.disk.color,
		alpha = text_attr.disk.alpha,
		x = rings.x + (i == 1 and -rings.disk.text_gap_x or rings.disk.text_gap_x),
		y = rings.y - (rings_ext_r + rings.disk.text_gap_y),
		align_x = (i == 1 and ALIGNR or ALIGNL),
		align_y = ALIGNB
	}
end

---------------------------------------
-- Core Temp text
---------------------------------------
local temp_x = math.floor(rings.x + (rings_ext_r + rings.temp.text_gap_r)*math.sin(rings.temp.text_angle*(2*math.pi/360)))
local temp_y = math.floor(rings.y - (rings_ext_r + rings.temp.text_gap_r)*math.cos(rings.temp.text_angle*(2*math.pi/360)))

text_table['templabel'] = {
	text = 'CORE TEMP',
	font = text_attr.label.font,
	fs = text_attr.label.fontsize,
	color = text_attr.label.color,
	alpha = text_attr.label.alpha,
	x = temp_x,
	y = temp_y,
	align_x = ALIGNL,
	align_y = ALIGNB
}

text_table['tempvalue'] = {
	text = '${hwmon coretemp temp 1}°C',
	font = text_attr.value.font,
	fs = text_attr.value.fontsize,
	color = text_attr.value.color,
	alpha = text_attr.value.alpha,
	x = temp_x + rings.temp.text_w,
	y = temp_y,
	align_x = ALIGNR,
	align_y = ALIGNB
}

---------------------------------------
-- Date text
---------------------------------------
text_table['date'] = {
	text = '${time %A, %d %B %Y}',
	font = text_attr.date.font,
	fs = text_attr.date.fontsize,
	color = text_attr.date.color,
	alpha = text_attr.date.alpha,
	-- x is calculated in main function
	x = 0,
	y = rings.y + rings.line.width/2 + rings.date.text_gap_y,
	align_x = ALIGNC,
	align_y = ALIGNT
}

---------------------------------------
-- NET text
---------------------------------------
local max_x = rings.x + rings_ext_r + rings.dummy.gap*4 + rings.dummy.width*2 + rings.graph.width

text_table['netlabel'] = {
	text = 'NET',
	font = text_attr.label.font,
	fs = text_attr.label.fontsize,
	color = text_attr.label.color,
	alpha = text_attr.label.alpha,
	x = max_x,
	y = rings.y - rings.line.width/2 - rings.net.text_gap_y,
	align_x = ALIGNL,
	align_y = ALIGNB
}

max_x = max_x + rings.net.text_w

text_table['netvalue'] = {
	text = '${downspeed '..net_interface..'}',
	font = text_attr.value.font,
	fs = text_attr.value.fontsize,
	color = text_attr.value.color,
	alpha = text_attr.value.alpha,
	x = max_x,
	y = rings.y - rings.line.width/2 - rings.net.text_gap_y,
	align_x = ALIGNR,
	align_y = ALIGNB
}

---------------------------------------
-- Main line
---------------------------------------
lines_table['main'] = {
	xs = rings.x + rings_ext_r + rings.line.gap, ys = rings.y,
	xe = max_x, ye = rings.y,
	dot = false,
	w = rings.line.width,
	color = rings_attr.bg_color,
	alpha = rings_attr.dummy_alpha
}

---------------------------------------
-- CPU top list
---------------------------------------
local topcpu_x = math.floor(rings.x + (rings_ext_r + rings.topcpu.text_gap_r)*math.sin(rings.topcpu.text_angle*(2*math.pi/360)))
local topcpu_y = math.floor(rings.y - (rings_ext_r + rings.topcpu.text_gap_r)*math.cos(rings.topcpu.text_angle*(2*math.pi/360)))

text_table['topcpulabel'] = {
	text = 'CPU',
	font = text_attr.label.font,
	fs = text_attr.label.fontsize,
	color = text_attr.label.color,
	alpha = text_attr.label.alpha,
	x = topcpu_x,
	y = topcpu_y,
	align_x = ALIGNL,
	align_y = ALIGNB
}

text_table['topcpuvalue'] = {
	text = '${cpu cpu0}%',
	font = text_attr.value.font,
	fs = text_attr.value.fontsize,
	color = text_attr.value.color,
	alpha = text_attr.value.alpha,
	x = topcpu_x + rings.topcpu.text_w,
	y = topcpu_y,
	align_x = ALIGNR,
	align_y = ALIGNB
}

lines_table['topcpu'] = {
	xs = topcpu_x, ys = topcpu_y + rings.topcpu.line_gap_y + rings.topcpu.line_w,
	xe = topcpu_x + rings.topcpu.text_w, ye = topcpu_y + rings.topcpu.line_gap_y + rings.topcpu.line_w,
	dot = true,
	w = rings.topcpu.line_w,
	color = other_attr.dotline.color,
	alpha = other_attr.dotline.alpha
}

topcpu_y = topcpu_y + rings.topcpu.line_gap_y*2 + rings.topcpu.line_w

text_table['topcpu_processlabel'] = {
	text = 'Processes:',
	font = text_attr.top.font,
	fs = text_attr.top.fontsize,
	color = text_attr.top.color,
	alpha = text_attr.top.alpha,
	x = topcpu_x,
	y = topcpu_y,
	align_x = ALIGNL,
	align_y = ALIGNT
}

text_table['topcpu_processvalue'] = {
	text = '${running_processes}/${processes}',
	font = text_attr.top.font,
	fs = text_attr.top.fontsize,
	color = text_attr.top.color,
	alpha = text_attr.top.alpha,
	x = topcpu_x + rings.topcpu.text_w,
	y = topcpu_y,
	align_x = ALIGNR,
	align_y = ALIGNT
}

topcpu_y = topcpu_y + rings.topcpu.text_space_y*1.5

for i = 1, rings.topcpu.n do
	text_table['topcpu_toplabel'..i] = {
		text = '${top name '..i..'}',
		font = text_attr.top.font,
		fs = text_attr.top.fontsize,
		color = text_attr.top.color,
		alpha = text_attr.top.alpha,
		x = topcpu_x,
		y = topcpu_y + (i-1)*rings.topcpu.text_space_y,
		align_x = ALIGNL,
		align_y = ALIGNT
	}

	text_table['topcpu_topvalue'..i] = {
		text = '${top cpu '..i..'}%',
		font = text_attr.top.font,
		fs = text_attr.top.fontsize,
		color = text_attr.top.color,
		alpha = text_attr.top.alpha,
		x = topcpu_x + rings.topcpu.text_w,
		y = topcpu_y + (i-1)*rings.topcpu.text_space_y,
		align_x = ALIGNR,
		align_y = ALIGNT
	}
end

---------------------------------------
-- MEM top list
---------------------------------------
local topmem_x = math.floor(rings.x + (rings_ext_r + rings.topmem.text_gap_r)*math.sin(rings.topmem.text_angle*(2*math.pi/360)))
local topmem_y = math.floor(rings.y - (rings_ext_r + rings.topmem.text_gap_r)*math.cos(rings.topmem.text_angle*(2*math.pi/360)))

text_table['topmemlabel'] = {
	text = 'RAM',
	font = text_attr.label.font,
	fs = text_attr.label.fontsize,
	color = text_attr.label.color,
	alpha = text_attr.label.alpha,
	x = topmem_x,
	y = topmem_y,
	align_x = ALIGNL,
	align_y = ALIGNB
}

text_table['topmemvalue'] = {
	text = '${memperc}%',
	font = text_attr.value.font,
	fs = text_attr.value.fontsize,
	color = text_attr.value.color,
	alpha = text_attr.value.alpha,
	x = topmem_x + rings.topmem.text_w,
	y = topmem_y,
	align_x = ALIGNR,
	align_y = ALIGNB
}

lines_table['topmem'] = {
	xs = topmem_x, ys = topmem_y + rings.topmem.line_gap_y + rings.topmem.line_w,
	xe = topmem_x + rings.topmem.text_w, ye = topmem_y + rings.topmem.line_gap_y + rings.topmem.line_w,
	dot = true,
	w = rings.topmem.line_w,
	color = other_attr.dotline.color,
	alpha = other_attr.dotline.alpha
}

topmem_y = topmem_y + rings.topmem.line_gap_y*2 + rings.topmem.line_w

for i = 1, rings.topmem.n do
	text_table['topmem_toplabel'..i] = {
		text = '${top_mem name '..i..'}',
		font = text_attr.top.font,
		fs = text_attr.top.fontsize,
		color = text_attr.top.color,
		alpha = text_attr.top.alpha,
		x = topmem_x,
		y = topmem_y + (i-1)*rings.topmem.text_space_y,
		align_x = ALIGNL,
		align_y = ALIGNT
	}

	text_table['topmem_topvalue'..i] = {
		text = '${top_mem mem '..i..'}%',
		font = text_attr.top.font,
		fs = text_attr.top.fontsize,
		color = text_attr.top.color,
		alpha = text_attr.top.alpha,
		x = topmem_x + rings.topmem.text_w,
		y = topmem_y + (i-1)*rings.topmem.text_space_y,
		align_x = ALIGNR,
		align_y = ALIGNT
	}
end

------------------------------------------------------------------------------
-- AUXILIARY FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function rgb_to_r_g_b
---------------------------------------
function rgb_to_r_g_b(color, alpha)
	return ((color/0x10000)%0x100)/255., ((color/0x100)%0x100)/255., (color%0x100)/255., alpha
end

---------------------------------------
-- Function get_conky_value
---------------------------------------
function get_conky_value(name, arg)
	local str = string.format('${%s %s}', name, arg)
	str = conky_parse(str)

	local value = tonumber(str)
	if value == nil then value = 0 end

	return(value)
end

------------------------------------------------------------------------------
-- DRAWING FUNCTIONS
------------------------------------------------------------------------------
---------------------------------------
-- Function draw_ring
---------------------------------------
function draw_ring(cr, pt)
	local value = get_conky_value(pt.name, pt.arg)

	local pct = value/pt.max
	pct = (pct > 1 and 1 or pct)

	local angle_0 = pt.start_angle*(2*math.pi/360) - math.pi/2
	local angle_f = pt.end_angle*(2*math.pi/360) - math.pi/2
	local t_arc = pct*(angle_f - angle_0)

	-- Draw background ring
	cairo_arc(cr, pt.x, pt.y, pt.radius, angle_0, angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.bg_color, pt.bg_alpha))
	cairo_set_line_width(cr, pt.width)
	cairo_stroke(cr)

	-- Draw indicator ring
	cairo_arc(cr, pt.x, pt.y, pt.radius, angle_0, angle_0 + t_arc)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.fg_color, pt.fg_alpha))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_clock_hands
---------------------------------------
function draw_clock_hands(cr, pt)
	local secs = os.date("%S")
	local mins = os.date("%M")
	local hours = os.date("%I")

	local secs_arc = (2*math.pi/60)*secs
	local mins_arc = (2*math.pi/60)*mins + secs_arc/60
	local hours_arc = (2*math.pi/12)*hours + mins_arc/12

	-- Draw hour hand
	draw_line(cr, {color = other_attr.clock.color, alpha = other_attr.clock.alpha, w = pt.hrs_width, xs = pt.x, ys = pt.y, xe = pt.x + (pt.radius - pt.hrs_gap)*math.sin(hours_arc), ye = pt.y - (pt.radius - pt.hrs_gap)*math.cos(hours_arc), dot = false})

	-- Draw minute hand
	draw_line(cr, {color = other_attr.clock.color, alpha = other_attr.clock.alpha, w = pt.min_width, xs = pt.x, ys = pt.y, xe = pt.x + (pt.radius - pt.min_gap)*math.sin(mins_arc), ye = pt.y - (pt.radius - pt.min_gap)*math.cos(mins_arc), dot = false})

	-- Draw seconds hand
	if pt.show_seconds then
		draw_line(cr, {color = other_attr.clock.color, alpha = other_attr.clock.alpha, w = pt.sec_width, xs = pt.x, ys = pt.y, xe = pt.x + (pt.radius - pt.sec_gap)*math.sin(secs_arc), ye = pt.y - (pt.radius - pt.sec_gap)*math.cos(secs_arc), dot = false})
	end
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
	local text_x = ((pt.align_x == ALIGNR) and (pt.x - t_extents.width - t_extents.x_bearing) or ((pt.align_x == ALIGNC) and (pt.x - t_extents.width*0.5 - t_extents.x_bearing*0.5) or pt.x))
	local text_y = ((pt.align_y == ALIGNT) and (pt.y + f_extents.height - f_extents.descent*2) or ((pt.align_y == ALIGNM) and (pt.y + f_extents.height/2 - f_extents.descent) or pt.y))

	-- Draw text
	cairo_move_to(cr, text_x, text_y)
	cairo_text_path(cr, text)
	cairo_set_line_width(cr, 0.3)
	cairo_stroke_preserve(cr)
	cairo_fill(cr)

	-- Destroy structures
	tolua.releaseownership(f_extents)
	cairo_font_extents_t:destroy(f_extents)

	tolua.releaseownership(t_extents)
	cairo_text_extents_t:destroy(t_extents)
end

---------------------------------------
-- Function draw_line
---------------------------------------
function draw_line(cr, pt)
	cairo_save(cr)

	cairo_move_to(cr, pt.xs, pt.ys)
	cairo_line_to(cr, pt.xe, pt.ye)

	cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)

	if pt.dot then
		cairo_set_dash(cr, {1,3}, 2, 0)
	end

	cairo_set_line_width(cr, pt.w)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))
	cairo_stroke(cr)

	cairo_restore(cr)
end

---------------------------------------
-- Function draw_graph
---------------------------------------
function draw_graph(cr, pt)
	cairo_save(cr)

	-- Get number of bars
	local n_bars = math.floor(pt.w/(pt.bar_w + pt.bar_gap))

	-- Update graph data
	for i = 1, n_bars do
		if pt.data[i+1] == nil then pt.data[i+1] = 0 end

		pt.data[i] = pt.data[i+1]

		if i == n_bars then
			pt.data[n_bars] = get_conky_value(pt.name, pt.arg)
		end
	end

	-- Draw graph bars
	local bar_h

	cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
	cairo_set_line_width(cr, pt.bar_w)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.color, pt.alpha))

	for i = 1, n_bars do
		-- Transform to log scale
		if pt.log_scale then
			bar_h = (math.log10(pt.data[i])/math.log10(pt.max))*pt.h
		else
			bar_h = (pt.data[i]/pt.max)*pt.h
		end

		-- Check limits of bar height
		if bar_h < 0 then bar_h = 0 end
		if bar_h > pt.h then bar_h = pt.h end

		-- Draw bar only if at least 1 full pixel height
		if bar_h >= 1 then
			cairo_move_to(cr, pt.x + (pt.bar_w/2) + ((i-1)*(pt.bar_w + pt.bar_gap)), pt.y)
			cairo_rel_line_to(cr, 0, -bar_h)
			cairo_stroke(cr)
		end
	end

	cairo_restore(cr)
end

------------------------------------------------------------------------------
-- MAIN FUNCTION
------------------------------------------------------------------------------
function conky_main()
	if conky_window == nil then return end

	-- Check network interface status
	local gw_up = tonumber(conky_parse('${if_up '..lan_interface..'}2${else}${if_up '..wifi_interface..'}1${else}0${endif}${endif}'))

	local check_interface = ((gw_up == 2) and lan_interface or ((gw_up == 1) and wifi_interface or 'None'))

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Draw rings
	for id, ring in pairs(rings_table) do
		if id:find('net') then
			ring.value = ring.value:gsub(net_interface, check_interface)
		end
		draw_ring(cr, ring)
	end

	-- Draw text
	for id, text in pairs(text_table) do
		if id == 'date' then
			text.x = (rings_table['dummy1'].x + rings_table['dummy1'].radius + rings_table['dummy2'].x + rings_table['dummy2'].radius)/2
		end
		if id:find('net') then
			text.text = text.text:gsub(net_interface, check_interface)
		end
		draw_text(cr, text)
	end

	-- Draw clock hands
	draw_clock_hands(cr, clock_hands)

	-- Draw graphs
	for id, graph in pairs(graphs_table) do
		if id:find('net') then
			graph.arg = check_interface
		end
		draw_graph(cr, graph)
	end

	-- Draw lines
	for id, line in pairs(lines_table) do
		draw_line(cr, line)
	end

	-- Update network variables
	net_interface = check_interface

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
