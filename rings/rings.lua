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
	r = 60, w = 10,
	gap = 2,
	sa = 0, ea = 235,
	neg = false,

	n = 4
}

for i = 1, cpu_rings.n do
	local ri = cpu_rings.r + (cpu_rings.n - i)*(cpu_rings.w + cpu_rings.gap)

	rings_table['cpu'..i] = {
		name = 'cpu',
		arg = 'cpu'..i,
		max = 100,
		x = cpu_rings.x, y = cpu_rings.y,
		r = ri,
		w = cpu_rings.w,
		sa = cpu_rings.sa,
		ea = cpu_rings.ea,
		neg = cpu_rings.neg,
		attr = rings_attr
	}
end

---------------------------------------
-- MEM variables
---------------------------------------
mem_rings = {
	x = 325, y = 280,
	r = 55, w = 17,
	gap = 3,
	sa = -180, ea = 55,
	neg = false,

	vars = { 'swapperc', 'memperc' }
}

for i in pairs(mem_rings.vars) do
	local ri = mem_rings.r + (i - 1)*(mem_rings.w + mem_rings.gap)

	rings_table['mem'..i] = {
		name = mem_rings.vars[i],
		arg = '',
		max = 100,
		x = mem_rings.x, y = mem_rings.y,
		r = ri,
		w = mem_rings.w,
		sa = mem_rings.sa,
		ea = mem_rings.ea,
		neg = mem_rings.neg,
		attr = rings_attr
	}
end

---------------------------------------
-- FS variables
---------------------------------------
fs_rings = {
	x = 370, y = 115,
	r = 27, w = 14,
	gap = 3,
	sa = 125, ea = 360,
	neg = true,

	paths = { '/home', '/', '/home/data' }
}

for i in pairs(fs_rings.paths) do
	local ri = fs_rings.r + (i - 1)*(fs_rings.w + fs_rings.gap)

	rings_table['fs'..i] = {
		name = 'fs_used_perc',
		arg = fs_rings.paths[i],
		max = 100,
		x = fs_rings.x, y = fs_rings.y,
		r = ri,
		w = fs_rings.w,
		sa = fs_rings.sa,
		ea = fs_rings.ea,
		neg = fs_rings.neg,
		attr = rings_attr
	}
end

-- ---------------------------------------
-- -- TIME variables
-- ---------------------------------------
time_rings = {
	x = 170, y = 310,
	r = 20, w = { 9, 11, 14 },
	gap = 3,
	sa = -55, ea = 180,
	neg = true,

	vars = {
		{ arg = '%S', max = 60 },
		{ arg = '%M', max = 60 },
		{ arg = '%H', max = 24 }
	}
}

for i in pairs(time_rings.vars) do
	local ri = time_rings.r
	for j = 2, i do
		ri = ri + (time_rings.w[j] + time_rings.w[j-1])/2 + time_rings.gap
	end

	rings_table['time'..i] = {
		name = 'time',
		arg = time_rings.vars[i].arg,
		max = time_rings.vars[i].max,
		x = time_rings.x, y = time_rings.y,
		r = ri,
		w = time_rings.w[i],
		sa = time_rings.sa,
		ea = time_rings.ea,
		neg = time_rings.neg,
		attr = rings_attr
	}
end

---------------------------------------
-- NET variables
---------------------------------------
net_rings = {
	x = 320, y = 440,
	r = 27, w = 16,
	gap = 3,
	sa = -180, ea = 55,
	neg = false,

	-- Max values in KB/s
	vars = {
		{ name = 'upspeedf', max = 1500 },
		{ name = 'downspeedf', max = 1500 },
	}
}


net_interface = 'wlp3s0'

for i in pairs(net_rings.vars) do
	local ri = net_rings.r + (i - 1)*(net_rings.w + net_rings.gap)

	rings_table['net'..i] = {
		name = net_rings.vars[i].name,
		arg = net_interface,
		max = net_rings.vars[i].max,
		x = net_rings.x, y = net_rings.y,
		r = ri,
		w = net_rings.w,
		sa = net_rings.sa,
		ea = net_rings.ea,
		neg = net_rings.neg,
		attr = rings_attr
	}
end

---------------------------------------
-- BAT variables
---------------------------------------
bat_rings = {
	x = 215, y = 415,
	r = 10, w = { 20, 12 },
	gap = 3,
	sa = { -180, -55 }, ea = { 180, 180 },
	neg = true,

	vars = {
		{ name = 'goto', arg = 0 },
		{ name = 'battery_percent', arg = '' },
	}
}


for i in pairs(bat_rings.vars) do
	local ri = bat_rings.r
	for j = 2, i do
		ri = ri + (bat_rings.w[j] + bat_rings.w[j-1])/2 + bat_rings.gap
	end

	rings_table['bat'..i] = {
		name = bat_rings.vars[i].name,
		arg = bat_rings.vars[i].arg,
		max = 100,
		x = bat_rings.x, y = bat_rings.y,
		r = ri,
		w = bat_rings.w[i],
		sa = bat_rings.sa[i],
		ea = bat_rings.ea[i],
		neg = bat_rings.neg,
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
	local value = get_conky_string(pt.name, pt.arg)

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
	if pt.neg == true then
		cairo_arc_negative(cr, pt.x, pt.y, pt.r, angle_f, angle_f - t_arc)
	else
		cairo_arc(cr, pt.x, pt.y, pt.r, angle_0, angle_0 + t_arc)
	end
	cairo_set_source_rgba(cr, rgb_to_r_g_b(pt.attr.fgc, pt.attr.fga))
	cairo_stroke(cr)
end

---------------------------------------
-- Function conky_rings
---------------------------------------
function conky_rings()
	if conky_window == nil then return end

	net_interface=conky_parse("${if_up ${template1}}${template1}${else}${if_up ${template0}}${template0}${else}none${endif}${endif}")

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	local cr = cairo_create(cs)

	for id, ring in pairs(rings_table) do
		if id:find('net') then ring.arg = net_interface end
		draw_ring(cr, ring)
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
