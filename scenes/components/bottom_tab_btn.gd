@tool
extends Control
class_name BottomTabClass

signal BtnPressed()


@export var icon : Texture2D = null:
	set(value):
		icon = value
		if is_node_ready():
			_ready()
	get:
		return icon
		
@export var title := "מידע":
	set(value):
		title = value
		if is_node_ready():
			_ready()
	get:
		return title
		
@export var default_selected := false:
	set(value):
		default_selected = value
		if is_node_ready():
			_ready()
	get:
		return default_selected

var _is_selected = false
func _ready() -> void:
	$VList/TextureRect.texture = icon
	$VList/custom_label.text = title
	if default_selected:
		$Selected.visible = true
		$VList/TextureRect.self_modulate = GlobalColor.COLOR_TEXT_GREEN
		$VList/custom_label.label_color = "PRIMARY"
	else:
		$Selected.visible = false
		$VList/TextureRect.self_modulate = GlobalColor.COLOR_TEXT_NEUTRAL
		$VList/custom_label.label_color = "NEUTRAL"
	_is_selected = default_selected
		
	if !Engine.is_editor_hint():
		GlobalBtn.AddBtnPress(self)
		GlobalBtn.BtnPress.connect(OnTabSelected)
		GlobalSignals.BottomTabSelected.connect(OnBottomTabSelected)
	
	
func OnBottomTabSelected(bottom_tab:BottomTabClass):
	if bottom_tab == self:
		if !_is_selected:
			BtnPressed.emit()
		AnimateSelected()
	else:
		AnimateUnSelected()

func AnimateSelected():
	if !_is_selected:
		_is_selected = true
		$Selected.self_modulate.a = 0.0
		$Selected.visible = true
		var t = create_tween()
		t.tween_property($Selected,"self_modulate:a",1.0,0.1)
		t.parallel().tween_property($VList/TextureRect,"self_modulate",GlobalColor.COLOR_TEXT_GREEN,0.1)
		$VList/custom_label.label_color = "PRIMARY"
	
func AnimateUnSelected():
	if _is_selected:
		_is_selected = false
		var t = create_tween()
		t.tween_property($Selected,"self_modulate:a",0.0,0.1)
		t.parallel().tween_property($VList/TextureRect,"self_modulate",GlobalColor.COLOR_TEXT_NEUTRAL,0.1)
		$VList/custom_label.label_color = "NEUTRAL"
		t.finished.connect(func():$Selected.visible = false)
	
func OnTabSelected(tab_control:Control):
	if tab_control != self:
		return
	GlobalBtn.AnimateBtnPressed(self)
	GlobalSignals.BottomTabSelected.emit(self)
