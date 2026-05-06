extends VBoxContainer


func _on_v_list_resized() -> void:
	var max_y = $Panel/VList.get_minimum_size().y
	$Panel.custom_minimum_size.y = max_y+40
