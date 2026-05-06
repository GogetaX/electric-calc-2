@tool
extends Control

signal OnPress()

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
		
	if !Engine.is_editor_hint():
		if as_button:
			GlobalBtn.AddBtnPress(self)
			GlobalBtn.BtnPress.connect(OnBtnPress)
			
func OnBtnPress(btn_control:Control):
	if btn_control != self:
		return
	GlobalBtn.AnimateBtnPressed($Panel)
	OnPress.emit()
