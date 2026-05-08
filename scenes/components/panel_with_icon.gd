@tool
extends Control

signal OnPress()

@export_enum("PRIMARY","PRIMARY_INVERTED","SECONDARY","TERITIARY","NEUTRAL","WHITE") var label_color := "SECONDARY":
	set(value):
		label_color = value
		if is_node_ready():
			_ready()
			
	get:
		return label_color

@export var icon : Texture2D = null:
	set(value):
		icon = value
		if is_node_ready():
			_ready()
	get:
		return icon
		
@export var as_button := false
@export var hide_bg := false:
	set(value):
		hide_bg = value
		if is_node_ready():
			_ready()
	get:
		return hide_bg
		
func _ready() -> void:
	$Panel/TextureRect.texture = icon
	if hide_bg:
		$Panel.self_modulate.a = 0.0
	else:
		$Panel.self_modulate.a = 1.0
		
	match label_color:
		"SECONDARY":
			$Panel/TextureRect.self_modulate = Color("#F59E0B")
		"PRIMARY":
			$Panel/TextureRect.self_modulate = GlobalColor.COLOR_TEXT_GREEN
		"PRIMARY_INVERTED":
			$Panel/TextureRect.self_modulate = Color("#003824")
		"TERITIARY":
			$Panel/TextureRect.self_modulate = Color("#94A3B8")
		"NEUTRAL":
			$Panel/TextureRect.self_modulate = GlobalColor.COLOR_TEXT_NEUTRAL
		"WHITE":
			$Panel/TextureRect.self_modulate = Color.WHITE
		_:
			print_debug("Unknown color: ",label_color)
		
	if !Engine.is_editor_hint():
		if as_button:
			GlobalBtn.AddBtnPress(self)
			GlobalBtn.BtnPress.connect(OnBtnPress)
			
func OnBtnPress(btn_control:Control):
	if btn_control != self:
		return
	GlobalBtn.AnimateBtnPressed($Panel)
	OnPress.emit()
