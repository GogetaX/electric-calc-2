@tool
extends Label

@onready var font_normal = preload("res://assets/fonts/NotoSansHebrew-Regular.ttf")
@onready var font_bold = preload("res://assets/fonts/NotoSansHebrew-Bold.ttf")

@export_enum("PRIMARY","PRIMARY_INVERTED","SECONDARY","TERITIARY","NEUTRAL","WHITE") var label_color := "SECONDARY":
	set(value):
		label_color = value
		if is_node_ready():
			_ready()
			
	get:
		return label_color
		
@export_enum("TOP_BAR","NORMAL","NORMAL_BOLD","NORMAL_TITLE","INPUT_BOLD") var label_size := "TOP_BAR":
	set(value):
		label_size = value
		if is_node_ready():
			_ready()
	get:
		return label_size
		
func _ready() -> void:
	match label_color:
		"SECONDARY":
			add_theme_color_override("font_color",Color("#F59E0B"))
		"PRIMARY":
			add_theme_color_override("font_color",GlobalColor.COLOR_TEXT_GREEN)
		"PRIMARY_INVERTED":
			add_theme_color_override("font_color",Color("#003824"))
		"TERITIARY":
			add_theme_color_override("font_color",Color("#94A3B8"))
		"NEUTRAL":
			add_theme_color_override("font_color",GlobalColor.COLOR_TEXT_NEUTRAL)
		"WHITE":
			add_theme_color_override("font_color",Color.WHITE)
		_:
			print_debug("Unknown color: ",label_color)
	match label_size:
		"TOP_BAR":
			add_theme_font_size_override("font_size",40)
			add_theme_font_override("font",font_bold)
		"NORMAL":
			add_theme_font_size_override("font_size",24)
			add_theme_font_override("font",font_normal)
		"NORMAL_BOLD":
			add_theme_font_size_override("font_size",24)
			add_theme_font_override("font",font_bold)
		"NORMAL_TITLE":
			add_theme_font_size_override("font_size",32)
			add_theme_font_override("font",font_normal)
		"INPUT_BOLD":
			add_theme_font_size_override("font_size",32+16)
			add_theme_font_override("font",font_bold)
		_:
			print_debug("Unknown size: ",label_size)
	
