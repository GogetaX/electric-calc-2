extends Panel

func _ready() -> void:
	_on_v_list_resized()
	

func _on_v_list_resized() -> void:
	await get_tree().process_frame
	var max_y = $VList.get_minimum_size().y
	custom_minimum_size.y = max_y + 40
