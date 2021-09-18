---------------------------------------
-- Ring variables
---------------------------------------
ring_x = 220
ring_y = 145
ring_radius = 70
ring_spacing = 4

ring_color_bg = 0x383c4a
ring_color_fg = 0x383c4a
ring_alpha_bg = 0.20
ring_alpha_fg = 0.60
ring_alpha_bg_dummy = 0.20
ring_alpha_fg_dummy = 0

cpu_start_angle = 91
cpu_end_angle = 209
cpu_width = 4
cpu_radius = ring_radius + 9
cpu_spacing = 6

memtemp_radius = ring_radius + 18
memtemp_width = 22

fs_radius = ring_radius + 37
fs_width = 6

dummy_radius = ring_radius + 60
dummy_width = 2

---------------------------------------
-- Clock variables
---------------------------------------
clock_r = ring_radius - 5
clock_x = ring_x
clock_y = ring_y
clock_color = 0x5294E2
clock_alpha = 1.0
clock_show_seconds = false

---------------------------------------
-- Line variables
---------------------------------------
line_solid_width = 2
line_dotted_width = 1
line_solid_color = 0x383c4a
line_dotted_color = 0x383c4a
line_solid_alpha = ring_alpha_bg_dummy
line_dotted_alpha = 0.70

---------------------------------------
-- Graph variables
---------------------------------------
graph_color = 0x383c4a
graph_alpha = 0.7
graph_bar_width = 1
graph_bar_gap = 0

---------------------------------------
-- NET variables
---------------------------------------
net_interface = 'wlp3s0'
-- Max download
net_max_dl = 26000

---------------------------------------
-- Settings table
---------------------------------------
rings_table = {
	-- TIME -------------------------------
	{
		name = 'time',
		arg = '%S',
		max = 60,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = ring_radius,
		width = 4,
		start_angle = 0,
		end_angle = 360
	},
	-- CPU --------------------------------
	{
		name = 'cpu',
		arg = 'cpu1',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = cpu_radius,
		width = cpu_width,
		start_angle = cpu_start_angle,
		end_angle = cpu_end_angle
	},
	{
		name = 'cpu',
		arg = 'cpu2',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = cpu_radius + cpu_spacing,
		width = cpu_width,
		start_angle = cpu_start_angle,
		end_angle = cpu_end_angle
	},
	{
		name = 'cpu',
		arg = 'cpu3',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = cpu_radius + 2*cpu_spacing,
		width = cpu_width,
		start_angle = cpu_start_angle,
		end_angle = cpu_end_angle
	},
	{
		name = 'cpu',
		arg = 'cpu4',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = cpu_radius + 3*cpu_spacing,
		width = cpu_width,
		start_angle = cpu_start_angle,
		end_angle = cpu_end_angle
	},
	-- MEM --------------------------------
	{
		name = 'memperc',
		arg = '',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = memtemp_radius,
		width = memtemp_width,
		start_angle = 212,
		end_angle = 329
	},
	-- TEMP -------------------------------
	{
		name = 'acpitemp',
		arg = '',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = memtemp_radius,
		width = memtemp_width,
		start_angle = -28,
		end_angle = 88
	},
	-- FS ---------------------------------
	{
		name = 'fs_used_perc',
		arg = '/',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = fs_radius,
		width = fs_width,
		start_angle = -120,
		end_angle = -2
	},
	{
		name = 'fs_used_perc',
		arg = '/home/data',
		max = 100,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg,
		x = ring_x, y = ring_y,
		radius = fs_radius,
		width = fs_width,
		start_angle = 2,
		end_angle = 120
	},
	-- DUMMY ------------------------------
	{
		name = 'cpu', -- dummy (used for arc around graph)
		arg = '',
		max = 1,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg_dummy,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg_dummy,
		x = ring_x, y = ring_y,
		radius = dummy_radius,
		width = dummy_width,
		start_angle = 73,
		end_angle = 107
	},
	{
		name = 'cpu', -- dummy (used for arc around graph)
		arg = '',
		max = 1,
		bg_color = ring_color_bg,
		bg_alpha = ring_alpha_bg_dummy,
		fg_color = ring_color_fg,
		fg_alpha = ring_alpha_fg_dummy,
		x = ring_x + 470, y = ring_y,
		radius = dummy_radius,
		width = dummy_width,
		start_angle = 73,
		end_angle = 107
	},
}

lines_table = {
	{
		color = line_dotted_color,
		alpha = line_dotted_alpha,
		w = line_dotted_width,
		xs = 30, ys = 295,
		xe = 211, ye = 295,
		dot=true
	},
	{
		color = line_dotted_color,
		alpha = line_dotted_alpha,
		w = line_dotted_width,
		xs = 300, ys = 269,
		xe = 481, ye = 269,
		dot=true
	},
	{
		color = line_solid_color,
		alpha = line_solid_alpha,
		w = line_solid_width,
		xs = ring_x + ring_radius+46, ys = ring_y,
		xe = 980, ye = ring_y,
		dot=false
	},
}

graphs_table = {
	downspeed = {
		name = 'downspeedf',
		arg = net_interface,
		max = net_max_dl,
		color = graph_color,
		alpha = graph_alpha,
		x = ring_x + ring_radius + 78, y = ring_y - 1,
		w = 432, h = 26,
		bar_w = graph_bar_width,
		bar_gap = graph_bar_gap,
		data = {},
		log_scale = true
	}
}

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
-- Function get_conky_value
---------------------------------------
function get_conky_value(name, arg)

	local str = string.format('${%s %s}', name, arg)
	str = conky_parse(str)

	local value = tonumber(str)
	if value == nil then value = 0 end

	return(value)
end

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
function draw_clock_hands(cr, xc, yc)
	local secs = os.date("%S")
	local mins = os.date("%M")
	local hours = os.date("%I")

	local secs_arc = (2*math.pi/60)*secs
	local mins_arc = (2*math.pi/60)*mins + secs_arc/60
	local hours_arc = (2*math.pi/12)*hours + mins_arc/12

	local hours_len = 0.7

	-- Draw hour hand
	draw_line(cr, {color = clock_color, alpha = clock_alpha, w = 5, xs = xc, ys = yc, xe = xc + (hours_len*clock_r)*math.sin(hours_arc), ye = yc - (hours_len*clock_r)*math.cos(hours_arc), dot = false})

	-- Draw minute hand
	draw_line(cr, {color = clock_color, alpha = clock_alpha, w = 3, xs = xc, ys = yc, xe = xc + clock_r*math.sin(mins_arc), ye = yc - clock_r*math.cos(mins_arc), dot = false})

	-- Draw seconds hand
	if clock_show_seconds then
		draw_line(cr, {color = clock_color, alpha = clock_alpha, w = 1, xs = xc, ys = yc, xe = xc + clock_r*math.sin(secs_arc), ye = yc - clock_r*math.cos(secs_arc), dot = false})
	end
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
	-- Get number of bars
	local n_bars = pt.w/(pt.bar_w + pt.bar_gap)

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

	cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
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
end

---------------------------------------
-- Function conky_clock_rings
---------------------------------------
function conky_clock_rings()
	if conky_window == nil then return end

	net_interface = conky_parse("${if_up ${template1}}${template1}${else}${if_up ${template0}}${template0}${else}none${endif}${endif}")

	graphs_table.downspeed.arg = net_interface

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	-- Draw rings
	for i in pairs(rings_table) do
		draw_ring(cr, rings_table[i])
	end

	-- Draw clock hands
	draw_clock_hands(cr, clock_x, clock_y)

	-- Draw graphs
	for i in pairs(graphs_table) do
		draw_graph(cr, graphs_table[i])
	end

	-- Draw lines
	for i in pairs(lines_table) do
		draw_line(cr, lines_table[i])
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
