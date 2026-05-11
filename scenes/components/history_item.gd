extends Panel

var cur_data = {}


func InitItem(item_data:Dictionary):
	cur_data = item_data
	if item_data.has("from_old_save") && item_data.from_old_save:
		InitOldData()
	else:
		InitNewData()
		

func InitNewData():
	$HList/VList/HBoxContainer/calculated_kw.text = str(cur_data.tot_kw).pad_decimals(2) + " קוט״ש"
	$HList/VList4/last_date.text = Global.date_dict_to_string(cur_data.to_date)
	$HList/VList/HBoxContainer/days_passed.text = str(cur_data.days_passed).pad_decimals(0)+" יום"
	$HList/VList4/last_kw.text = str(cur_data.from_kw).pad_decimals(0)+" → "+str(cur_data.to_kw).pad_decimals(0)
	$HList/VList/last_pay.text = "₪" + str(cur_data.tot_pay).pad_decimals(2)
	
func InitOldData():
	if !cur_data.last_date.is_empty():
		$HList/VList4/last_date.text = Global.date_dict_to_string(cur_data.last_date)
	else:
		$HList/VList4/last_date.text = ""
	
	$HList/VList/last_pay.text = cur_data.last_pay
	$HList/VList4/last_kw.text = str(cur_data.prev_kw).pad_decimals(0)+" → "+str(cur_data.cur_kw).pad_decimals(0)
	
	if cur_data.prev_date.is_empty() || cur_data.last_date.is_empty():
		$HList/VList/HBoxContainer/days_passed.text = ""
		$HList/VList/HBoxContainer/date_spacer.text = ""
	else:
		var days_passed = Global.GetDaysPassed(cur_data.prev_date,cur_data.last_date)
		$HList/VList/HBoxContainer/days_passed.text = str(days_passed).pad_decimals(0)+"יום "
		
	var calculateed_kw = cur_data.cur_kw - cur_data.prev_kw
	$HList/VList/HBoxContainer/calculated_kw.text = str(calculateed_kw).pad_decimals(2) + " קוט״ש"


func _on_panel_with_icon_on_press() -> void:
	GlobalSignals.ShowPopup.emit("DISPLAY_RECEPIE",cur_data)
