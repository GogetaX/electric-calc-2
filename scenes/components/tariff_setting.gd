@tool
extends Panel

signal SettingPressed()

@export_enum("PRIMARY","PRIMARY_INVERTED","SECONDARY","TERITIARY","NEUTRAL","WHITE") var label_color := "SECONDARY":
	set(value):
		label_color = value
		if is_node_ready():
			_ready()
			
	get:
		return label_color
		
@export var title := "תשלום קבוע":
	set(value):
		title = value
		if is_node_ready():
			_ready()
	get:
		return title
		
@export var value_str := "₪0.6432":
	set(value):
		value_str = value
		if is_node_ready():
			_ready()
	get:
		return value_str
		
@export var with_selector := false:
	set(value):
		with_selector = value
		if is_node_ready():
			_ready()
	get:
		return with_selector
		

var _already_inited = false
func _ready() -> void:
	$VList/title_label.text = title
	$VList/HBoxContainer/value.text = value_str
	$VList/HBoxContainer/TypeSelectorBtn.visible = with_selector
	$VList/HBoxContainer/value.label_color = label_color
	if !Engine.is_editor_hint() && !_already_inited:
		_already_inited = true
		$VList/HBoxContainer/TypeSelectorBtn.OnPress.connect(OnSettingPressed)

	
func OnSettingPressed():
	SettingPressed.emit()
