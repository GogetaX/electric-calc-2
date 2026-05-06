@tool
extends Panel

@export var title := "תעריף ביתי":
	set(value):
		title = value
		if is_node_ready():
			_ready()
	get:
		return title

@export var icon :Texture2D = null:
	set(value):
		icon = value
		if is_node_ready():
			_ready()
	get:
		return icon
		
@export var description := "תעריף ביתי":
	set(value):
		description = value
		if is_node_ready():
			_ready()
	get:
		return description
		
@export var value_str := "₪64.32":
	set(value):
		value_str = value
		if is_node_ready():
			_ready()
	get:
		return value_str
		
@export var last_update := "עודכן לאחרונה: 2024":
	set(value):
		last_update = value
		if is_node_ready():
			_ready()
	get:
		return last_update
		
@export var hide_spacer := false:
	set(value):
		hide_spacer = value
		if is_node_ready():
			_ready()
	get:
		return hide_spacer
		
@export var hide_right_side := false:
	set(value):
		hide_right_side = value
		if is_node_ready():
			_ready()
	get:
		return hide_right_side
		
		
func _ready() -> void:
	$VList/HList/title.text = title
	$VList/HList/icon.icon = icon
	$VList/desc.text = description
	$VList/HList2/value.text = value_str
	$VList/HList2/last_update.text = last_update
	
	$VList/Spacer.visible = !hide_spacer
	$VList/HList2.visible = !hide_spacer
	
	$VList/HList2/custom_label5.visible = !hide_right_side
	$VList/HList2/value.visible = !hide_right_side
	$VList/HList2/custom_label6.visible = !hide_right_side
	_on_v_list_resized()
	
func _on_v_list_resized() -> void:
	var max_y = $VList.get_minimum_size().y
	custom_minimum_size.y = max_y + 40
