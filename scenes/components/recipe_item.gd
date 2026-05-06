@tool
extends HBoxContainer


@export var title := "צריכה":
	set(value):
		title = value
		if is_node_ready():
			_ready()
	get:
		return title
		
@export var value_str := "500 קוט״ש":
	set(value):
		value_str = value
		if is_node_ready():
			_ready()
	get:
		return value_str
		
func _ready() -> void:
	$title.text = title
	$value.text = value_str
