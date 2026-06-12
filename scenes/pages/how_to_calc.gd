extends VBoxContainer


func _on_v_list_resized() -> void:
	await get_tree().process_frame
	var max_y = $Panel/VList.get_minimum_size().y
	$Panel.custom_minimum_size.y = max_y+40
