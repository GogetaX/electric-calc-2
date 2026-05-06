extends Panel

var cur_data = {}

var settings_before_save :Dictionary = {"division_percent":0,"division_custom_price":0,"division_part_price":0,"division_type":""}

func _ready() -> void:
	for x:TaarifTabClass in $VList/CustomerTypeContainer.get_children():
		x.OnPress.connect(UpdateTabData)
	for x:TaarifTabClass in $VList/DevisionList.get_children():
		x.OnPress.connect(UpdateDevision)
		
func InitData(data):
	cur_data = data
	match cur_data.type:
		"HOUSE":
			$VList/HBoxContainer2/customer_type.text = "לקוח ביתי"
			var house_settings = GlobalLoader.save_data.house_settings
			$VList/Percentage/HList/percent_div_value.text = str(house_settings.division_data.PERCENT_VALUE).pad_decimals(0)
			$VList/KavuaPrice/HList/custom_div_value.text = str(house_settings.division_data.CUSTOM_PRICE).pad_decimals(2)
			$VList/PartPrice/HList/part_div_value.text = str(house_settings.division_data.PART_DIV_VALUE).pad_decimals(0)
			
			
			SetSelectedTab(house_settings.phase_type)
			SetSelectedDevisionTab(house_settings.division_data)
		"DEFAULT":
			$VList/HBoxContainer2/customer_type.text = "לקוח כללי"
			var default_settings = GlobalLoader.save_data.default_settings
			$VList/Percentage/HList/percent_div_value.text = str(default_settings.division_data.PERCENT_VALUE).pad_decimals(0)
			$VList/KavuaPrice/HList/custom_div_value.text = str(default_settings.division_data.CUSTOM_PRICE).pad_decimals(2)
			$VList/PartPrice/HList/part_div_value.text = str(default_settings.division_data.PART_DIV_VALUE).pad_decimals(0)
			SetSelectedTab(default_settings.phase_type)
			SetSelectedDevisionTab(default_settings.division_data)
		"CUSTOM":
			$VList/HBoxContainer2/customer_type.text = "מותאם אישית"
			var custom_settings = GlobalLoader.save_data.default_settings
			$VList/Percentage/HList/percent_div_value.text = str(custom_settings.division_data.PERCENT_VALUE).pad_decimals(0)
			$VList/KavuaPrice/HList/custom_div_value.text = str(custom_settings.division_data.CUSTOM_PRICE).pad_decimals(2)
			$VList/PartPrice/HList/part_div_value.text = str(custom_settings.division_data.PART_DIV_VALUE).pad_decimals(0)
			SetSelectedTab(custom_settings.phase_type)
			SetSelectedDevisionTab(custom_settings.division_data)
			
	$VList/Total/TotalList/HList3/maam_percent.text = str(GlobalCalcDb.MAAM*100.0).pad_decimals(0) + " %"
	UpdateDevision()
	UpdateTabData()
	#UpdateTotals()

func UpdateTotals():
	var last_date_data = GlobalLoader.get_closest_last_date_item(GlobalLoader.save_data.history)
	settings_before_save["division_percent"] = $VList/Percentage/HList/percent_div_value.text
	settings_before_save["division_custom_price"] = $VList/KavuaPrice/HList/custom_div_value.text 
	settings_before_save["division_part_price"] = $VList/PartPrice/HList/part_div_value.text
	
	if !last_date_data.is_empty():
		var last_date = last_date_data.get("last_date",Time.get_date_dict_from_system())
		var days_passed = Global.GetDaysPassed(last_date,Time.get_date_dict_from_system())
		$VList/Total/TotalList/HList/days_passed.text = str(days_passed).pad_decimals(0)
		var pay_per_month = CalcPayPerMonth()
		var need_to_pay = pay_per_month
		if days_passed == 0:
			pay_per_month = 0
			need_to_pay = 0
		else:
			need_to_pay = Global.calculate_payment_by_days(pay_per_month,last_date,Time.get_date_dict_from_system())
		need_to_pay = GlobalCalcDb.CalculateDevition(GetSelectedDivData(),cur_data.type,need_to_pay,last_date,Time.get_date_dict_from_system(),settings_before_save)
		#Maam:
		need_to_pay = need_to_pay + (need_to_pay*GlobalCalcDb.MAAM)
		
		$VList/Total/TotalList/HList2/need_to_pay.text = "₪ " + str(need_to_pay).pad_decimals(2)
	

	
	
func CalcPayPerMonth():
	var haluka_data = GlobalCalcDb.GetData(cur_data.type)
	var cur_selected_tab = GetCurSelectedTabData()
	var haluka = haluka_data.kavua_division.get(cur_selected_tab,0.0)
	var supply = haluka_data.kavua_supply.get(cur_selected_tab,0.0)
	if cur_selected_tab != "single_month_customer":
		haluka = haluka / 2.0
		supply = supply / 2.0
	return haluka + supply
	
func SetSelectedDevisionTab(div_data:Dictionary):
	for x:TaarifTabClass in $VList/DevisionList.get_children():
		x.SetAsUnSelected()
	await get_tree().process_frame
	match div_data.type:
		"NO_DIVISION":
			$VList/DevisionList/NoChangePrice.SetAsSelected()
		"DIV_PART":
			$VList/DevisionList/PartPrice.SetAsSelected()
		"PERCENT":
			$VList/DevisionList/PercentPrice.SetAsSelected()
		"CUSTOM":
			$VList/DevisionList/CustomPrice.SetAsSelected()
		_:
			print_debug("Unknown type: ",div_data.type)
			$VList/DevisionList/NoChangePrice.SetAsSelected()
	
func UpdateDevision():
	$VList/Percentage.visible = false
	$VList/KavuaPrice.visible = false
	$VList/PartPrice.visible = false
	var cur_div = GetSelectedDivData()
	match cur_div:
		"PERCENT":
			$VList/Percentage.visible = true
		"CUSTOM":
			$VList/KavuaPrice.visible = true
		"DIV_PART":
			$VList/PartPrice.visible = true
			
		"NO_DIVISION":
			pass
			
		_:
			print_debug("Unknown Div: ",cur_div)
	UpdateTotals()
	settings_before_save["division_type"] = cur_div

func GetSelectedDivData():
	for x : TaarifTabClass in $VList/DevisionList.get_children():
		if x.IsSelected():
			return x.setting_name
	return "NO_DIVISION"
				
func UpdateTabData():
	var haluka_data = GlobalCalcDb.GetData(cur_data.type)
	var cur_selected_tab = GetCurSelectedTabData()
	$VList/Panel/HList/kavua_haluka.text = "₪ " + str(haluka_data.kavua_division.get(cur_selected_tab,0))
	$VList/Panel2/HList/kavua_aspaka.text = "₪ " + str(haluka_data.kavua_supply.get(cur_selected_tab,0))
	settings_before_save["customer_type"] = cur_selected_tab
	UpdateTotals()
	
func GetCurSelectedTabData():
	for x :TaarifTabClass in $VList/CustomerTypeContainer.get_children():
		if x.IsSelected():
			return x.setting_name
	return "2_month_base_1_phase"
func SetSelectedTab(tab_name:String):
	for x in $VList/CustomerTypeContainer.get_children():
		x.SetAsUnSelected()
	
	match tab_name:
		"2_month_base_1_phase":
			$VList/CustomerTypeContainer/TwoMonthOnePhase.SetAsSelected()
		"2_month_base_3_phase":
			$VList/CustomerTypeContainer/TwoMonthThreePhase.SetAsSelected()
		"single_month_customer":
			$VList/CustomerTypeContainer/OneMonth.SetAsSelected()
		_:
			print_debug("Unknown tab: ",tab_name)
	
	
func _on_hint_text_resized() -> void:
	var max_y = $VList/Panel3/HList/hint_text.get_minimum_size().y
	$VList/Panel3.custom_minimum_size.y = max_y + 40


func _on_total_list_resized() -> void:
	var max_y = $VList/Total/TotalList.get_minimum_size().y
	$VList/Total.custom_minimum_size.y = max_y + 40


func _on_v_list_resized() -> void:
	await get_tree().process_frame
	var max_y = $VList.get_minimum_size().y
	custom_minimum_size.y = max_y + 40
	await get_tree().process_frame
	await get_tree().process_frame
	size.y = custom_minimum_size.y
	position.y = 100
	


func _on_cancel_btn_on_press() -> void:
	GlobalSignals.HideCurPopup.emit()


func _on_percent_format_value_submited(_value: String) -> void:
	UpdateTotals()


func _on_custom_price_value_submited(_value: String) -> void:
	UpdateTotals()


func _on_part_price_value_submited(_value: String) -> void:
	UpdateTotals()


func _on_calc_btn_2_on_press() -> void:

	
	match cur_data.type:
		"HOUSE":
			GlobalLoader.save_data.house_settings.division_data.type = settings_before_save.division_type
			GlobalLoader.save_data.house_settings.division_data.PART_DIV_VALUE = settings_before_save.division_part_price
			GlobalLoader.save_data.house_settings.division_data.PERCENT_VALUE = settings_before_save.division_percent
			GlobalLoader.save_data.house_settings.division_data.CUSTOM_PRICE = settings_before_save.division_custom_price
			GlobalLoader.save_data.house_settings.phase_type = settings_before_save.customer_type
		"DEFAULT":
			GlobalLoader.save_data.default_settings.division_data.type = settings_before_save.division_type
			GlobalLoader.save_data.default_settings.division_data.PART_DIV_VALUE = settings_before_save.division_part_price
			GlobalLoader.save_data.default_settings.division_data.PERCENT_VALUE = settings_before_save.division_percent
			GlobalLoader.save_data.default_settings.division_data.CUSTOM_PRICE = settings_before_save.division_custom_price
			GlobalLoader.save_data.default_settings.phase_type = settings_before_save.customer_type
		"CUSTOM":
			GlobalLoader.save_data.custom_settings.division_data.type = settings_before_save.division_type
			GlobalLoader.save_data.custom_settings.division_data.PART_DIV_VALUE = settings_before_save.division_part_price
			GlobalLoader.save_data.custom_settings.division_data.PERCENT_VALUE = settings_before_save.division_percent
			GlobalLoader.save_data.custom_settings.division_data.CUSTOM_PRICE = settings_before_save.division_custom_price
			GlobalLoader.save_data.custom_settings.phase_type = settings_before_save.customer_type
	GlobalSignals.UpdateValues.emit()
	GlobalLoader.SyncSave()
	GlobalSignals.HideCurPopup.emit()
