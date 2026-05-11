extends Panel

func _ready() -> void:
	GlobalSignals.UpdateHebrewMonth.connect(OnUpdateHebrewMonth)
	_on_v_list_resized()
	$VList/Panel/HList/cur_date.text = Global.get_today_hebrew_month_year()
	if Global.has_hebrew_month != "":
		$VList/Panel/HList/hebrew_month.text = Global.has_hebrew_month
	
func OnUpdateHebrewMonth():
	if Global.has_hebrew_month != "":
		$VList/Panel/HList/hebrew_month.text = Global.has_hebrew_month
		


func _on_v_list_resized() -> void:
	await get_tree().process_frame
	var max_y = $VList.get_minimum_size().y
	custom_minimum_size.y = max_y + 40
