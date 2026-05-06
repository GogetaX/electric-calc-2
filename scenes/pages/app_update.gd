extends Panel


func PanelResized() -> void:
	var max_y = $VList/Panel/VList.get_minimum_size().y
	$VList/Panel.custom_minimum_size.y = max_y+40
	UpdateToCenter()

func UpdateToCenter():
	position = get_viewport_rect().size/2.0 - size / 2.0


func _on_v_list_resized() -> void:
	await get_tree().process_frame
	var max_y = $VList.get_minimum_size().y
	custom_minimum_size.y = max_y+40
	size.y = custom_minimum_size.y
	await get_tree().process_frame
	UpdateToCenter()


func _on_calc_btn_on_press() -> void:
	GlobalSignals.HideCurPopup.emit()
