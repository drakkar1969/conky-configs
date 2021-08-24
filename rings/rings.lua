---------------------------------------
-- Ring variables
---------------------------------------
color_bg=0x383c4a
color_fg=0x383c4a
alpha_bg=0.2
alpha_fg=0.6
alpha_fg_dummy=0

---------------------------------------
-- CPU variables
---------------------------------------
cpu_x=170
cpu_y=135
cpu_radius=60
cpu_thickness=10
cpu_spacing=cpu_thickness+2
cpu_start_angle=0
cpu_end_angle=235

---------------------------------------
-- MEM variables
---------------------------------------
mem_x=315
mem_y=280
mem_radius=55
mem_thickness=17
mem_spacing=mem_thickness+3
mem_start_angle=-180
mem_end_angle=55

---------------------------------------
-- FS variables
---------------------------------------
fs_x=360
fs_y=115
fs_radius=27
fs_thickness=14
fs_spacing=fs_thickness+3
fs_start_angle=125
fs_end_angle=360

fs1_id="/home/data"
fs2_id="/"
fs3_id="/home"

---------------------------------------
-- TIME variables
---------------------------------------
time_x=160
time_y=310
time_radius=20
time_thickness_1=9
time_thickness_2=11
time_thickness_3=14
time_spacing_1=time_thickness_1+4
time_spacing_2=time_thickness_2+4
time_start_angle=-55
time_end_angle=180

---------------------------------------
-- NET variables
---------------------------------------
net_x=310
net_y=440
net_radius=27
net_thickness=16
net_spacing=net_thickness+3
net_start_angle=-180
net_end_angle=55

net_interface='wlp3s0'
-- Max download in KB
net_max_dl=26000
-- MAx upload in KB
net_max_ul=1500

---------------------------------------
-- BAT variables
---------------------------------------
bat_x=205
bat_y=415
bat_radius=10
bat_thickness_1=bat_radius*2
bat_thickness_2=12
bat_spacing=bat_thickness_1-1
bat_start_angle_1=0
bat_end_angle_1=360
bat_start_angle_2=-55
bat_end_angle_2=180

---------------------------------------
-- Settings table
---------------------------------------
rings_table = {
	-- CPU --------------------------------
	{
		name='cpu',
		arg='cpu4',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=cpu_x, y=cpu_y,
		radius=cpu_radius,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle,
		neg=false
	},
	{
		name='cpu',
		arg='cpu3',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=cpu_x, y=cpu_y,
		radius=cpu_radius+cpu_spacing,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle,
		neg=false
	},
	{
		name='cpu',
		arg='cpu2',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=cpu_x, y=cpu_y,
		radius=cpu_radius+2*cpu_spacing,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle,
		neg=false
	},
	{
		name='cpu',
		arg='cpu1',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=cpu_x, y=cpu_y,
		radius=cpu_radius+3*cpu_spacing,
		thickness=cpu_thickness,
		start_angle=cpu_start_angle,
		end_angle=cpu_end_angle,
		neg=false
	},
	-- MEM --------------------------------
	{
		name='swapperc',
		arg='',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=mem_x, y=mem_y,
		radius=mem_radius,
		thickness=mem_thickness,
		start_angle=mem_start_angle,
		end_angle=mem_end_angle,
		neg=false
	},
	{
		name='memperc',
		arg='',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=mem_x, y=mem_y,
		radius=mem_radius+mem_spacing,
		thickness=mem_thickness,
		start_angle=mem_start_angle,
		end_angle=mem_end_angle,
		neg=false
	},
	-- FS --------------------------------
	{
		name='fs_used_perc',
		arg=fs3_id,
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=fs_x, y=fs_y,
		radius=fs_radius,
		thickness=fs_thickness,
		start_angle=fs_start_angle,
		end_angle=fs_end_angle,
		neg=true
	},
	{
		name='fs_used_perc',
		arg=fs2_id,
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=fs_x, y=fs_y,
		radius=fs_radius+fs_spacing,
		thickness=fs_thickness,
		start_angle=fs_start_angle,
		end_angle=fs_end_angle,
		neg=true
	},
	{
		name='fs_used_perc',
		arg=fs1_id,
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=fs_x, y=fs_y,
		radius=fs_radius+2*fs_spacing,
		thickness=fs_thickness,
		start_angle=fs_start_angle,
		end_angle=fs_end_angle,
		neg=true
	},
	-- TIME --------------------------------
	{
		name='time',
		arg='%M',
		max=60,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=time_x, y=time_y,
		radius=time_radius,
		thickness=time_thickness_1,
		start_angle=time_start_angle,
		end_angle=time_end_angle,
		neg=true
	},
	{
		name='time',
		arg='%H',
		max=24,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=time_x, y=time_y,
		radius=time_radius+time_spacing_1,
		thickness=time_thickness_2,
		start_angle=time_start_angle,
		end_angle=time_end_angle,
		neg=true
	},
	{
		name='time',
		arg='%u',
		max=7,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=time_x, y=time_y,
		radius=time_radius+time_spacing_1+time_spacing_2,
		thickness=time_thickness_3,
		start_angle=time_start_angle,
		end_angle=time_end_angle,
		neg=true
	},
	-- NET --------------------------------
	upspeed = {
		name='upspeedf',
		arg=net_interface,
		max=net_max_ul,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=net_x, y=net_y,
		radius=net_radius,
		thickness=net_thickness,
		start_angle=net_start_angle,
		end_angle=net_end_angle,
		neg=false
	},
	downspeed = {
		name='downspeedf',
		arg=net_interface,
		max=net_max_dl,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=net_x, y=net_y,
		radius=net_radius+net_spacing,
		thickness=net_thickness,
		start_angle=net_start_angle,
		end_angle=net_end_angle,
		neg=false
	},
	-- BAT --------------------------------
	{
		name='battery_percent',
		arg='',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg_dummy,
		x=bat_x, y=bat_y,
		radius=bat_radius,
		thickness=bat_thickness_1,
		start_angle=bat_start_angle_1,
		end_angle=bat_end_angle_1,
		neg=true
	},
	{
		name='battery_percent',
		arg='',
		max=100,
		bg_colour=color_bg,
		bg_alpha=alpha_bg,
		fg_colour=color_fg,
		fg_alpha=alpha_fg,
		x=bat_x, y=bat_y,
		radius=bat_radius+bat_spacing,
		thickness=bat_thickness_2,
		start_angle=bat_start_angle_2,
		end_angle=bat_end_angle_2,
		neg=true
	},
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
	local neg=pt['neg']

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
	if neg == true then
		cairo_arc_negative(cr,xc,yc,ring_r,angle_f,angle_f-t_arc)
	else
		cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
	end
	cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
	cairo_stroke(cr)
end

---------------------------------------
-- Function conky_rings
---------------------------------------
function conky_rings()
	if conky_window==nil then return end

	net_interface = conky_parse("${if_up ${template1}}${template1}${else}${if_up ${template0}}${template0}${else}none${endif}${endif}")

	rings_table['upspeed']['arg'] = net_interface
	rings_table['downspeed']['arg'] = net_interface

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	for i in pairs(rings_table) do
		draw_ring(cr,rings_table[i])
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
