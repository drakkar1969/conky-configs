---------------------------------------
-- Ring variables
---------------------------------------
ring_x=220
ring_y=145
ring_radius=70
ring_spacing=4

ring_color_bg=0x383c4a
ring_color_fg=0x383c4a
ring_alpha_bg=0.20 -- 0.30
ring_alpha_fg=0.60 -- 0.80
ring_alpha_bg_dummy=0.20 -- 0.80
ring_alpha_fg_dummy=0

cpu_start_angle=91
cpu_end_angle=209
cpu_thickness=4
cpu_radius=ring_radius+9
cpu_spacing=6

memtemp_radius=ring_radius+18
memtemp_thickness=22

fs_radius=ring_radius+37
fs_thickness=6

dummy_radius=ring_radius+60
dummy_thickness=2

---------------------------------------
-- Clock variables
---------------------------------------
clock_r=ring_radius-5
clock_x=ring_x
clock_y=ring_y
clock_color=0x5294E2
clock_alpha=1.0
clock_show_seconds=false

---------------------------------------
-- Line variables
---------------------------------------
line_solid_width=2
line_dotted_width=1
line_solid_color=0x383c4a
line_dotted_color=0x383c4a
line_solid_alpha=ring_alpha_bg_dummy
line_dotted_alpha=0.70

---------------------------------------
-- Graph variables
---------------------------------------
graph_color=0x383c4a
graph_alpha=0.7
graph_thickness=2
graph_spacing=0

---------------------------------------
-- NET variables
---------------------------------------
net_interface='wlp3s0'
-- Max download
net_max_dl=26000

---------------------------------------
-- Settings table
---------------------------------------
rings_table = {
	{
	-- TIME -------------------------------
	name='time',
		arg='%S',
		max=60,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=ring_radius,
		thickness=4,
		start_angle=0,
		end_angle=360
	},
	-- CPU --------------------------------
	{
		name='cpu',
		arg='cpu1',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=cpu_radius,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle
	},
	{
		name='cpu',
		arg='cpu2',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=cpu_radius+cpu_spacing,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle
	},
	{
		name='cpu',
		arg='cpu3',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=cpu_radius+2*cpu_spacing,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle
	},
	{
		name='cpu',
		arg='cpu4',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=cpu_radius+3*cpu_spacing,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle
	},
	-- MEM --------------------------------
	{
		name='memperc',
		arg='',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=memtemp_radius,
		thickness=memtemp_thickness,
		start_angle=212,
		end_angle=329
	},
	-- TEMP -------------------------------
	{
		name='acpitemp',
		arg='',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=memtemp_radius,
		thickness=memtemp_thickness,
		start_angle=-28,
		end_angle=88
	},
	-- FS ---------------------------------
	{
		name='fs_used_perc',
		arg='/',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=fs_radius,
		thickness=fs_thickness,
		start_angle=-120,
		end_angle=-2
	},
	{
		name='fs_used_perc',
		arg='/home/data',
		max=100,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg,
		x=ring_x, y=ring_y,
		radius=fs_radius,
		thickness=fs_thickness,
		start_angle=2,
		end_angle=120
	},
	-- DUMMY ------------------------------
	{
		name='cpu', -- dummy (used for arc)
		arg='',
		max=1,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg_dummy,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg_dummy,
		x=ring_x, y=ring_y,
		radius=dummy_radius,
		thickness=dummy_thickness,
		start_angle=73,
		end_angle=107
	},
	{
		name='cpu', -- dummy (used for arc)
		arg='',
		max=1,
		bg_colour=ring_color_bg,
		bg_alpha=ring_alpha_bg_dummy,
		fg_colour=ring_color_fg,
		fg_alpha=ring_alpha_fg_dummy,
		x=ring_x+470, y=ring_y,
		radius=dummy_radius,
		thickness=dummy_thickness,
		start_angle=73,
		end_angle=107
	},
}

lines_solid_table = {
	{
		xs=ring_x+ring_radius+46, ys=ring_y,
		xe=980, ye=ring_y
	},
}

lines_dotted_table = {
	{
		xs=30, ys=295,
		xe=211, ye=295
	},
	{
		xs=300, ys=269,
		xe=481, ye=269
	},
}

graphs_table = {
	{
		name='downspeedf',
		arg=net_interface,
		max=net_max_dl,
		color=graph_color,
		alpha=graph_alpha,
		x=ring_x+ring_radius+78, y=ring_y-1,
		w=432, h=26,
		thickness=graph_thickness,
		spacing=graph_spacing,
		data={}
	}
}

---------------------------------------
-- LUA FUNCTIONS
---------------------------------------
require 'cairo'

---------------------------------------
-- Function rgb_to_r_g_b
---------------------------------------
function rgb_to_r_g_b(colour,alpha)
	return ((colour/0x10000)%0x100)/255.,((colour/0x100)%0x100)/255.,(colour%0x100)/255.,alpha
end

---------------------------------------
-- Function get_conky_string
---------------------------------------
function get_conky_string(name,arg)
	local str=''
	local value=0

	str=string.format('${%s %s}',name,arg)
	str=conky_parse(str)

	value=tonumber(str)
	if value == nil then value = 0 end

	return(value)
end

---------------------------------------
-- Function draw_ring
---------------------------------------
function draw_ring(cr,pt)
	local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
	local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

	local value=get_conky_string(pt['name'],pt['arg'])

	local pct=value/pt['max']
	pct=(pct > 1 and 1 or pct)

	local angle_0=sa*(2*math.pi/360)-math.pi/2
	local angle_f=ea*(2*math.pi/360)-math.pi/2
	local t_arc=pct*(angle_f-angle_0)

	-- Draw background ring
	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
	cairo_set_line_width(cr,ring_w)
	cairo_stroke(cr)

	-- Draw indicator ring
	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_clock_hands
---------------------------------------
function draw_clock_hands(cr,xc,yc)
	local secs,mins,hours,secs_arc,mins_arc,hours_arc
	local xh,yh,xm,ym,xs,ys

	secs=os.date("%S")
	mins=os.date("%M")
	hours=os.date("%I")

	secs_arc=(2*math.pi/60)*secs
	mins_arc=(2*math.pi/60)*mins+secs_arc/60
	hours_arc=(2*math.pi/12)*hours+mins_arc/12

	-- Draw hour hand
	xh=xc+0.7*clock_r*math.sin(hours_arc)
	yh=yc-0.7*clock_r*math.cos(hours_arc)
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xh,yh)

	cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
	cairo_set_line_width(cr,5)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(clock_color,clock_alpha))
	cairo_stroke(cr)

	-- Draw minute hand
	xm=xc+clock_r*math.sin(mins_arc)
	ym=yc-clock_r*math.cos(mins_arc)
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xm,ym)

	cairo_set_line_width(cr,3)
	cairo_stroke(cr)

	-- Draw seconds hand
	if clock_show_seconds then
		xs=xc+clock_r*math.sin(secs_arc)
		ys=yc-clock_r*math.cos(secs_arc)
		cairo_move_to(cr,xc,yc)
		cairo_line_to(cr,xs,ys)

		cairo_set_line_width(cr,1)
		cairo_stroke(cr)
	end
end

---------------------------------------
-- Function draw_solid_line
---------------------------------------
function draw_solid_line(cr,pt)
	local xs,ys,xe,ye=pt['xs'],pt['ys'],pt['xe'],pt['ye']

	cairo_move_to(cr,xs,ys)
	cairo_line_to(cr,xe,ye)

	cairo_set_line_cap(cr,CAIRO_LINE_CAP_SQUARE)
	cairo_set_line_width(cr,line_solid_width)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(line_solid_color,line_solid_alpha))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_dotted_line
---------------------------------------
function draw_dotted_line(cr,pt)
	local xs,ys,xe,ye=pt['xs'],pt['ys'],pt['xe'],pt['ye']

	cairo_move_to(cr,xs,ys)
	cairo_line_to(cr,xe,ye)

	cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
	cairo_set_dash(cr,{1,3},2,0)
	cairo_set_line_width(cr,line_dotted_width)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(line_dotted_color,line_dotted_alpha))
	cairo_stroke(cr)
end

---------------------------------------
-- Function draw_graph
---------------------------------------
function draw_graph(cr,pt)
	local data=pt['data']
	local x,y,w,h=pt['x'],pt['y'],pt['w'],pt['h']
	local thickness,spacing=pt['thickness'],pt['spacing']
	local color,alpha=pt['color'],pt['alpha']
	local max=pt['max']

	local num_bars=w/(thickness+spacing)

	local value=get_conky_string(pt['name'],pt['arg'])

	for i = 1, num_bars do
		if data[i+1] == nil then data[i+1]=0 end

		data[i]=data[i+1]

		if i == num_bars then
			data[num_bars]=value
		end
	end

	for i = 1, num_bars do
		-- Check that log of data[i] will not be negative
		if data[i] < 1 then data[i]=1 end

		-- Transform to log scale
		bar_h=(math.log10(data[i])/math.log10(max))*h

		-- Check limits of bar height
		if bar_h < 0 then bar_h=0 end
		if bar_h > h then bar_h=h end

		-- Draw bar only if at least 1 full pixel height
		if bar_h >= 1 then
			cairo_move_to(cr,x+(thickness/2)+((i-1)*(thickness+spacing)),y)
			cairo_line_to(cr,x+(thickness/2)+((i-1)*(thickness+spacing)),y-bar_h)

			cairo_set_line_width(cr,thickness)
			cairo_set_source_rgba(cr,rgb_to_r_g_b(color,alpha))
			cairo_stroke(cr)
		end
	end
end

---------------------------------------
-- Function conky_clock_rings
---------------------------------------
function conky_clock_rings()
	if conky_window==nil then return end

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	-- Draw rings
	for i in pairs(rings_table) do
		draw_ring(cr,rings_table[i])
	end

	-- Draw clock hands
	draw_clock_hands(cr,clock_x,clock_y)

	-- Draw graphs
	for i in pairs(graphs_table) do
		draw_graph(cr,graphs_table[i])
	end

	-- Draw solid lines
	for i in pairs(lines_solid_table) do
		draw_solid_line(cr,lines_solid_table[i])
	end

	-- Draw dotted lines
	for i in pairs(lines_dotted_table) do
		draw_dotted_line(cr,lines_dotted_table[i])
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
