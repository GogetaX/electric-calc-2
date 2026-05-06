@tool
extends Control
class_name TaarifTabClass

signal OnPress()

@export_multiline() var tab_name := "ביתי":
	set(value):
		tab_name = value
		if is_node_ready():
			_ready()
	get:
		return tab_name
		
@export_enum("TOP_BAR","NORMAL","NORMAL_BOLD","NORMAL_TITLE","INPUT_BOLD") var label_size := "TOP_BAR":
	set(value):
		label_size = value
		if is_node_ready():
			_ready()
	get:
		return label_size
		
@export var tab_id = "tab"

@export var setting_name := ""

var _is_selected = false

func _ready() -> void:
	$Selected/custom_label.text = tab_name
	$UnSelected/custom_label.text = tab_name
	$Selected/custom_label.label_size = label_size
	$UnSelected/custom_label.label_size = label_size
	$UnSelected.visible = true
	$Selected.visible = false
	if !Engine.is_editor_hint():
		GlobalSignals.TariffSelected.connect(OnTaarifSelected)
		GlobalBtn.AddBtnPress(self)
		GlobalBtn.BtnPress.connect(OnBtnPress)

func OnBtnPress(btn_press:Control):
	if btn_press != self:
		return
	GlobalBtn.AnimateBtnPressed(self)
	GlobalSignals.TariffSelected.emit(self)
	OnPress.emit()
	
func OnTaarifSelected(taarif_node:TaarifTabClass):
	if taarif_node.tab_id != tab_id:
		return
	if taarif_node == self:
		SetAsSelected()
	else:
		SetAsUnSelected()

func IsSelected():
	return _is_selected
	
func SetAsSelected():
	if !_is_selected:
		_is_selected = true
		$Selected.modulate.a = 0.0
		$Selected.visible = true
		var t = create_tween()
		t.tween_property($Selected,"modulate:a",1.0,0.1)
		t.parallel().tween_property($UnSelected,"modulate:a",0.0,0.1)
		t.finished.connect(func():$UnSelected.visible = false)
	
func SetAsUnSelected():
	if _is_selected:
		_is_selected = false
		$UnSelected.modulate.a = 0.0
		$UnSelected.visible = true
		var t = create_tween()
		t.tween_property($UnSelected,"modulate:a",1.0,0.1)
		t.parallel().tween_property($Selected,"modulate:a",0.0,0.1)
		t.finished.connect(func():$Selected.visible = false)
