extends Panel

func InitItem(item_data:Dictionary):
	print(item_data)
	if !item_data.prev_date.is_empty():
		$HList/VList2/prev_date.text = Global.DictToDateStr(item_data.prev_date)
	else:
		$HList/HBoxContainer/right_arrow.vertical_alignment = 2
		$HList/VList2/prev_date.text = ""
	
	if !item_data.last_date.is_empty():
		$HList/VList4/last_date.text = Global.DictToDateStr(item_data.last_date)
	else:
		$HList/VList4/last_date.text = ""
	
	$HList/VList/last_pay.text = item_data.last_pay
	$HList/VList2/prev_kw.text = str(item_data.prev_kw).pad_decimals(0)
	$HList/VList4/last_kw.text = str(item_data.cur_kw).pad_decimals(0)
	
	if item_data.prev_date.is_empty() || item_data.last_date.is_empty():
		$HList/VList/HBoxContainer/days_passed.text = ""
		$HList/VList/HBoxContainer/date_spacer.text = ""
	else:
		var days_passed = Global.GetDaysPassed(item_data.prev_date,item_data.last_date)
		$HList/VList/HBoxContainer/days_passed.text = str(days_passed).pad_decimals(0)+"יום "
		
	var calculateed_kw = item_data.cur_kw - item_data.prev_kw
	$HList/VList/HBoxContainer/calculated_kw.text = str(calculateed_kw).pad_decimals(0) + " קוט״ש"
