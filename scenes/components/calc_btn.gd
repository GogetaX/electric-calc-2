@tool
extends Control
signal OnPress()

@export var title := "חשב":
	set(value):
		title = value
		if is_node_ready():
			_ready()
	get:
		return title

func _ready() -> void:
	$custom_label.text = title
	if !Engine.is_editor_hint():
		GlobalBtn.AddBtnPress(self)
		GlobalBtn.BtnPress.connect(OnBtnPress)
		
func OnBtnPress(btn_node:Control):
	if btn_node != self:
		return
	GlobalBtn.AnimateBtnPressed(self)
	OnPress.emit()
