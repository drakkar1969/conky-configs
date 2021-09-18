---------------------------------------
-- Function get_ring_geom
---------------------------------------
function get_ring_geom(i, gt)
	local ot = {}

	-- Copy single values
	for k, v in pairs({'x', 'y', 'ccw'}) do ot[v] = gt[v] end

	-- Get values from tables
	for k, v in pairs({'w', 'sa', 'ea'}) do ot[v] = ((type(gt[v]) == 'table') and gt[v][i] or gt[v]) end

	-- Calculate radius of indiviudal rings
	ot.r = gt.ri
	for j = 2, i do
		ot.r = ot.r + ((type(gt.w) == 'table') and ((gt.w[j] + gt.w[j-1])/2) or gt.w) + gt.gap
	end

	return(ot)
end

---------------------------------------
-- Ring variables
---------------------------------------
rings_attr = {
	bgc = 0x383c4a,
	bga = 0.2,
	fgc = 0x383c4a,
	fga = 0.6,
}

rings_table = {}

---------------------------------------
-- CPU variables
---------------------------------------
cpu_rings = {
	x = 180, y = 135,
	ri = 60, w = 10,
	gap = 2,
	sa = 0, ea = 235,
	ccw = false
}

n_cpu = 4

for i = 1, n_cpu do
	rings_table['cpu'..i] = {
		vars = { name = 'cpu', arg = 'cpu'..(n_cpu - i + 1), max = 100 },
		geom = get_ring_geom(i, cpu_rings),
		attr = rings_attr
	}
end

---------------------------------------
-- FS variables
---------------------------------------
fs_rings = {
	x = 370, y = 115,
	ri = 27, w = 14,
	gap = 3,
	sa = 125, ea = 360,
	ccw = true
}

fs_vars = {
	{ name = 'fs_used_perc', arg = '/home', max = 100},
	{ name = 'fs_used_perc', arg = '/', max = 100},
	{ name = 'fs_used_perc', arg = '/home/data', max = 100}
}

for i in pairs(fs_vars) do
	rings_table['fs'..i] = {
		vars = fs_vars[i],
		geom = get_ring_geom(i, fs_rings),
		attr = rings_attr
	}
end

---------------------------------------
-- MEM variables
---------------------------------------
mem_rings = {
	x = 325, y = 280,
	ri = 55, w = 17,
	gap = 3,
	sa = -180, ea = 55,
	ccw = false
}

mem_vars = {
	{ name = 'swapperc', arg = '', max = 100},
	{ name = 'memperc', arg = '', max = 100}
}

for i in pairs(mem_vars) do
	rings_table['mem'..i] = {
		vars = mem_vars[i],
		geom = get_ring_geom(i, mem_rings),
		attr = rings_attr
	}
end

---------------------------------------
-- TIME variables
---------------------------------------
time_rings = {
	x = 170, y = 310,
	ri = 20, w = { 9, 11, 14 },
	gap = 3,
	sa = -55, ea = 180,
	ccw = true
}

time_vars = {
	{ name = 'time', arg = '%S', max = 60 },
	{ name = 'time', arg = '%M', max = 60 },
	{ name = 'time', arg = '%H', max = 24 }
}

for i in pairs(time_vars) do
	rings_table['time'..i] = {
		vars = time_vars[i],
		geom = get_ring_geom(i, time_rings),
		attr = rings_attr
	}
end

---------------------------------------
-- BAT variables
---------------------------------------
bat_rings = {
	x = 220, y = 410,
	ri = 10, w = { 20, 12 },
	gap = 3,
	sa = { -180, -55 }, ea = { 180, 180 },
	ccw = true,
}

bat_vars = {
	{ name = 'goto', arg = 0, max = 100 },
	{ name = 'battery_percent', arg = '', max = 100 },
}

for i in pairs(bat_vars) do
	rings_table['bat'..i] = {
		vars = bat_vars[i],
		geom = get_ring_geom(i, bat_rings),
		attr = rings_attr
	}
end

---------------------------------------
-- NET variables
---------------------------------------
net_rings = {
	x = 320, y = 440,
	ri = 27, w = 16,
	gap = 3,
	sa = -180, ea = 55,
	ccw = false
}

net_interface = 'wlp3s0'
-- Max values in KB/s
net_vars = {
	{ name = 'upspeedf', arg = net_interface, max = 1500 },
	{ name = 'downspeedf', arg = net_interface, max = 10000 },
}

for i in pairs(net_vars) do
	rings_table['net'..i] = {
		vars = net_vars[i],
		geom = get_ring_geom(i, net_rings),
		attr = rings_attr
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
-- Function get_conky_string
---------------------------------------
function get_conky_string(name, arg)
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
	local value = get_conky_string(pt.vars.name, pt.vars.arg)

	local pct = value/pt.vars.max
	pct = (pct > 1 and 1 or pct)

	local angle_0 = pt.geom.sa*(2*math.pi/360) - math.pi/2
	local angle_f = pt.geom.ea*(2*math.pi/360) - math.pi/2
	local t_arc = pct*(angle_f - angle_0)

	-- Draw background ring
	cairo_arc(cr, pt.geom.x, pt.geom.y, pt.geom.r, angle_0, angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.bgc, pt.attr.bga))
	cairo_set_line_width(cr, pt.geom.w)
	cairo_stroke(cr)

	-- Draw indicator ring
	if pt.geom.ccw == true then
		cairo_arc_negative(cr, pt.geom.x, pt.geom.y, pt.geom.r, angle_f, angle_f - t_arc)
	else
		cairo_arc(cr, pt.geom.x, pt.geom.y, pt.geom.r, angle_0, angle_0 + t_arc)
	end
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.fgc, pt.attr.fga))
	cairo_stroke(cr)
end

---------------------------------------
-- Function conky_rings
---------------------------------------
function conky_rings()
	if conky_window == nil then return end

	net_interface=conky_parse('${if_up ${template1}}${template1}${else}${if_up ${template0}}${template0}${else}none${endif}${endif}')

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	for id, ring in pairs(rings_table) do
		if id:find('net') then ring.vars.arg = net_interface end
		draw_ring(cr, ring)
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
