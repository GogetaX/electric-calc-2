extends Panel

var max_y_size = 0

func _on_v_list_resized() -> void:
	max_y_size = $VList.get_minimum_size().y + 40
	custom_minimum_size.y = max_y_size
