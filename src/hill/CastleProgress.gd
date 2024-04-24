extends ProgressBar

func _ready():
	min_value = 0
	max_value = 1
	value = 0.5
	
	var border_width = 1
	var border_radius = 1
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color("d8caf9") # Background color.
	bg_style.bg_color.a = 0.8
	bg_style.border_color = Color.WHITE # Border color.
	bg_style.border_color.a = 0.4
	bg_style.border_width_left = border_width
	bg_style.border_width_top = border_width
	bg_style.border_width_right = border_width
	bg_style.border_width_bottom = border_width
	bg_style.corner_radius_top_left = border_radius
	bg_style.corner_radius_top_right = border_radius
	bg_style.corner_radius_bottom_left = border_radius
	bg_style.corner_radius_bottom_right = border_radius
	bg_style.set_expand_margin_all(border_radius)
	bg_style.anti_aliasing = false
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.REBECCA_PURPLE # Fill color.
	fill_style.border_color = Color.WHITE
	fill_style.border_color.a = 0
	fill_style.border_width_left = border_width
	fill_style.border_width_top = border_width
	fill_style.border_width_right = border_width
	fill_style.border_width_bottom = border_width
	fill_style.corner_radius_top_left = border_radius
	fill_style.corner_radius_top_right = border_radius
	fill_style.corner_radius_bottom_left = border_radius
	fill_style.corner_radius_bottom_right = border_radius
	fill_style.set_expand_margin_all(border_radius)
	fill_style.anti_aliasing = false
	
	show_percentage = false
	
	add_theme_font_size_override("font_size", 0)
	add_theme_stylebox_override("fill", fill_style)
	add_theme_stylebox_override("background", bg_style)

