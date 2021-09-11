---------------------------------------
-- Dial variables
---------------------------------------
dial_color_fill=0x383c4a
dial_color_bg=0x383c4a
dial_color_fg=0x383c4a
dial_alpha_fill=0.1
dial_alpha_bg=0.2
dial_alpha_fg=0.6
dial_radius=50
dial_width=10
dial_start_angle=0
dial_end_angle=360
dial_gap=60

dial_x=0
dial_y=dial_radius+10
dial_count=0

text_font_perc="Ubuntu"
text_font_label="Ubuntu"
text_size_perc=28
text_size_label=14
text_color_perc=0x383c4a
text_color_label=0x21232b
text_alpha_perc=1
text_alpha_label=1
label_gap=12

---------------------------------------
-- NET variables
---------------------------------------
net_interface='wlp3s0'

---------------------------------------
-- Settings table
---------------------------------------
dials_table = {
	core = {
		index=0,
		label='Core Temp',
		suffix='°C',
		name='acpitemp',
		arg=''
	},
	cpu = {
		index=1,
		label='CPU',
		suffix='%',
		name='cpu',
		arg='cpu0'
	},
	ram = {
		index=2,
		label='Memory',
		suffix='%',
		name='memperc',
		arg=''
	},
	home = {
		index=3,
		label='Home',
		suffix='%',
		name='fs_used_perc',
		arg='/home'
	},
	data = {
		index=4,
		label='Data',
		suffix='%',
		name='fs_used_perc',
		arg='/home/data'
	},
	battery = {
		index=5,
		label='Battery',
		suffix='%',
		name='battery_percent',
		arg=''
	},
}

---------------------------------------
-- LUA FUNCTIONS
---------------------------------------
require 'cairo'

---------------------------------------
-- Function rgb_to_r_g_b
---------------------------------------
function rgb_to_r_g_b(color,alpha)
	return ((color/0x10000)%0x100)/255.,((color/0x100)%0x100)/255.,(color%0x100)/255.,alpha
end

---------------------------------------
-- Function get_conky_string
---------------------------------------
function get_conky_string(name,arg)
	local str=string.format('${%s %s}',name,arg)
	str=conky_parse(str)

	local value=tonumber(str)
	if value == nil then value=0 end

	return(value)
end

---------------------------------------
-- Function draw_dial
---------------------------------------
function draw_dial(cr,pt)
	local value=get_conky_string(pt.name,pt.arg)

	local pct=value/100
	pct=(pct > 1 and 1 or pct)

	local angle_0=dial_start_angle*(2*math.pi/360)-math.pi/2
	local angle_f=dial_end_angle*(2*math.pi/360)-math.pi/2
	local t_arc=pct*(angle_f-angle_0)

	local draw_x=conky_window.width/2+dial_x+pt.index*(2*dial_radius+dial_gap)

	-- Draw background fill
	cairo_arc(cr,draw_x,dial_y,dial_radius+dial_width/2-1,angle_0,angle_f)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(dial_color_fill,dial_alpha_fill))
	cairo_fill(cr)

	-- Draw background ring
	cairo_arc(cr,draw_x,dial_y,dial_radius,angle_0,angle_f)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(dial_color_bg,dial_alpha_bg))
	cairo_set_line_width(cr,dial_width)
	cairo_stroke(cr)

	-- Draw indicator ring
	cairo_arc(cr,draw_x,dial_y,dial_radius,angle_0,angle_0+t_arc)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(dial_color_fg,dial_alpha_fg))
	cairo_stroke(cr)

	-- Draw percentage text
	cairo_select_font_face(cr,text_font_perc,CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr,text_size_perc)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(text_color_perc,text_alpha_perc))

	local extents=cairo_text_extents_t:create()
	cairo_text_extents(cr,value..pt.suffix,extents)

	local text_x=draw_x-(extents.width/2)
	local text_y=dial_y+(extents.height/2)

	cairo_move_to(cr,text_x,text_y)
	cairo_show_text(cr,value..pt.suffix)
	cairo_stroke(cr)

	-- Draw label text
	cairo_select_font_face(cr,text_font_label,CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size(cr,text_size_label)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(text_color_label,text_alpha_label))

	cairo_text_extents(cr,pt.label,extents)
	text_x=draw_x-(extents.width/2)
	text_y=dial_y+dial_radius+(dial_width/2)+label_gap+extents.height

	cairo_move_to(cr,text_x,text_y)
	cairo_show_text(cr,pt.label)
	cairo_stroke(cr)
end

---------------------------------------
-- Function conky_set_coords
---------------------------------------
function conky_set_coords()
	-- Get dial count
	for i in pairs(dials_table) do dial_count=dial_count+1 end

	local left_count=math.floor(dial_count/2)

	-- If dial count is even
	if dial_count%2 == 0 then
		dial_x=(((left_count-1)*(dial_radius*2+dial_gap))+dial_radius+dial_gap/2)*-1
	-- If dial count is odd
	else
		dial_x=(left_count*(dial_radius*2+dial_gap))*-1
	end
end
---------------------------------------
-- Function conky_dials
---------------------------------------
function conky_dials()
	if conky_window==nil then return end

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	for i in pairs(dials_table) do
		draw_dial(cr,dials_table[i])
	end

	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
