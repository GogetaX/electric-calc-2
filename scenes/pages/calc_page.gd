extends VBoxContainer

@onready var history_item = preload("res://scenes/components/history_item.tscn")

var cur_selected_last_month = {}

func _ready() -> void:
	GlobalSignals.AppLoaded.connect(OnAppLoaded)
	GlobalSignals.UpdateValues.connect(OnUpdateValues)
	GlobalSignals.UpdateHistory.connect(OnUpdateHistory)
	if Global.has_hebrew_month == "":
		Global.get_hebrew_month_from_api()
	$ToPay.SetAsHidden()
	
func OnUpdateHistory():
	UpdateHistory()
	
func UpdateHistory():
	ClearAllHistory()
	var history = GlobalLoader.GetHistory(2)
	for x in history:
		var h = history_item.instantiate()
		$HistoryList.add_child(h)
		h.InitItem(x)
		
	var closest_month = GlobalLoader.get_closest_last_date_item(GlobalLoader.save_data.history)
	cur_selected_last_month = closest_month
	if !closest_month.is_empty():
		if closest_month.has("last_date"):
			cur_selected_last_month = closest_month.get("last_date",Time.get_date_dict_from_system())
			$HList/OldKW.SetInput(closest_month.get("cur_kw",0))
		elif closest_month.has("to_date"):
			cur_selected_last_month = closest_month.get("to_date",Time.get_date_dict_from_system())
			$HList/OldKW.SetInput(closest_month.get("to_kw",0))
		else:
			cur_selected_last_month = Time.get_date_dict_from_system()
			$HList/OldKW.SetInput(closest_month.get("cur_kw",0))
		
		$HList/NewKW.SetInput(-1)
	else:
		cur_selected_last_month = Time.get_date_dict_from_system()
		$HList/OldKW.SetInput(0)
		$HList/NewKW.SetInput(-1)
	
		
func OnAppLoaded():
	UpdateHistory()
		#$HistoryList.move_child(h,0)

	match GlobalLoader.GetCurSelectedTab():
		"HOUSE":
			$TaarifSelector/HomeTab.SetAsSelected()
		"DEFAULT":
			$TaarifSelector/DefaultTab.SetAsSelected()
		"CUSTOM":
			$TaarifSelector/CustomTab.SetAsSelected()
		_:
			print_debug("Unknown Selected tab: ",GlobalLoader.GetCurSelectedTab())
	SyncSelectedTab()
	UpdateKWCalc()
	
func OnUpdateValues():
	SyncSelectedTab()
	UpdateKWCalc()
	$ToPay.AnimateHide()
	
func SyncSelectedTab():
	$HouseTab.visible = false
	$DefaultTab.visible = false
	$CustomTab.visible = false
	match GlobalLoader.GetCurSelectedTab():
		"HOUSE":
			var data = GlobalCalcDb.GetData(GlobalLoader.GetCurSelectedTab())
			$HouseTab.visible = true
			$HouseTab/KotashPrice.value_str = "₪"+str(data.every_kw/100.0)
			$HouseTab/Kavua.value_str = "₪"+str(CalcKavua(GlobalLoader.GetCurSelectedTab())).pad_decimals(2)
			
		"DEFAULT":
			$DefaultTab.visible = true
			var data = GlobalCalcDb.GetData(GlobalLoader.GetCurSelectedTab())
			$DefaultTab/KotashPrice.value_str = "₪"+str(data.every_kw/100.0)
			$DefaultTab/Kavua.value_str = "₪"+str(CalcKavua(GlobalLoader.GetCurSelectedTab())).pad_decimals(2)
		"CUSTOM":
			$CustomTab.visible = true
			var data = GlobalCalcDb.GetData(GlobalLoader.GetCurSelectedTab())
			if GlobalLoader.GetCustomPricePer100KW() == -1:
				GlobalLoader.SetCustomPricePer100KW(data.every_kw)
			$CustomTab/CustomKotashPrice.value_str = "₪"+str(GlobalLoader.GetCustomPricePer100KW()).pad_decimals(2)
			$CustomTab/Kavua.value_str = "₪"+str(CalcKavua(GlobalLoader.GetCurSelectedTab())).pad_decimals(2)
		_:
			print_debug("Unknown Tab: ",GlobalLoader.GetCurSelectedTab())

func CalcKavua(data_type:String):
	var data_to_work_with = {}
	match data_type:
		"HOUSE":
			data_to_work_with = GlobalLoader.save_data.house_settings
		"DEFAULT":
			data_to_work_with = GlobalLoader.save_data.default_settings
		"CUSTOM":
			data_to_work_with = GlobalLoader.save_data.custom_settings
	
	var db_data = GlobalCalcDb.GetData(data_type)

	var kavua_division = db_data.kavua_division[data_to_work_with.phase_type]
	var kavua_supply = db_data.kavua_supply[data_to_work_with.phase_type]
	if data_to_work_with.phase_type != "single_month_customer":
		kavua_division /= 2.0
		kavua_supply /= 2.0
	var pay_per_month = kavua_division + kavua_supply
	var days_passed = Global.GetDaysPassed(cur_selected_last_month,Time.get_date_dict_from_system())
	var need_to_pay = 0
	if days_passed > 0:
		need_to_pay = Global.calculate_payment_by_days(pay_per_month,cur_selected_last_month,Time.get_date_dict_from_system())
	
		var settings_before_save :Dictionary = {"division_percent":data_to_work_with.division_data.PERCENT_VALUE,
		"division_custom_price":data_to_work_with.division_data.CUSTOM_PRICE,
		"division_part_price":data_to_work_with.division_data.PART_DIV_VALUE,
		"division_type":data_to_work_with.division_data.type}
		need_to_pay = GlobalCalcDb.CalculateDevition(data_to_work_with.division_data.type,data_type,need_to_pay,cur_selected_last_month,Time.get_date_dict_from_system(),settings_before_save)
		
		#Maam:
		if data_to_work_with.with_maam:
			need_to_pay = need_to_pay + (need_to_pay*GlobalCalcDb.MAAM)
		
	return need_to_pay
	
func ClearAllHistory():
	for x in $HistoryList.get_children():
		x.queue_free()


func _on_home_tab_on_press() -> void:
	GlobalLoader.SetCurTab("HOUSE")
	SyncSelectedTab()
	


func _on_default_tab_on_press() -> void:
	GlobalLoader.SetCurTab("DEFAULT")
	SyncSelectedTab()


func _on_custom_tab_on_press() -> void:
	GlobalLoader.SetCurTab("CUSTOM")
	SyncSelectedTab()


func _on_kavua_setting_pressed() -> void:
	GlobalSignals.ShowPopup.emit("KAVUA_CALC",{"type":GlobalLoader.GetCurSelectedTab()})


func _on_old_kw_value_submited(_value: float) -> void:
	$ToPay.AnimateHide()
	UpdateKWCalc()


func _on_new_kw_value_submited(_value: float) -> void:
	$ToPay.AnimateHide()
	UpdateKWCalc()
	
func UpdateKWCalc():
	var old_value = $HList/OldKW.GetValue()
	var new_value = $HList/NewKW.GetValue()
	$ResultInfo.UpdateResult(str(new_value)+" - "+str(old_value)+" =",str(new_value-old_value)+" Kwh")


func _on_calc_btn_on_press() -> void:
	var pay_data = GeneratePayData()
	$ToPay.AnimateShow()
	$ToPay.InitData(pay_data)

func GetEffectiveEveryKw(selected_tab: String, electric_data: Dictionary) -> float:
	var every_kw := float(electric_data.get("every_kw", 0.0))

	if selected_tab == "CUSTOM":
		var custom_price := float(GlobalLoader.GetCustomPricePer100KW())

		if custom_price < 0.0:
			custom_price = every_kw
			GlobalLoader.SetCustomPricePer100KW(custom_price)

		every_kw = custom_price

	return every_kw
	
func GeneratePayData():
	var res = {}
	#calc KW
	var old_value = $HList/OldKW.GetValue()
	var new_value = $HList/NewKW.GetValue()
	var tot_kw = abs(new_value - old_value)
	var selected_tab = GlobalLoader.GetCurSelectedTab()
	var electric_data = GlobalCalcDb.GetData(selected_tab).duplicate(true)
	var saved_settings = GlobalLoader.GetSettings(selected_tab)
	
	var every_kw := GetEffectiveEveryKw(selected_tab, electric_data)
	electric_data["every_kw"] = every_kw
	#Output recepie
	var pay_for_kw = (tot_kw * every_kw) / 100.0
	var pay_for_kw_with_maam = pay_for_kw + (pay_for_kw * GlobalCalcDb.MAAM)
	var with_maam = saved_settings.with_maam
	var kavua = CalcKavua(selected_tab)
	var days_passed = Global.GetDaysPassed(cur_selected_last_month,Time.get_date_dict_from_system())
	
	res["tot_kw"] = tot_kw
	res["from_date"] = cur_selected_last_month.duplicate(true)
	res["to_date"] = Time.get_date_dict_from_system()
	res["phase_type"] = saved_settings.phase_type
	res["division_data"] = saved_settings.division_data.duplicate(true)
	res["pay_for_kw"] = pay_for_kw
	res["pay_for_kw_with_maam"] = pay_for_kw_with_maam
	res["with_maam"] = with_maam
	res["kavua"] = kavua
	res["from_kw"] = old_value
	res["to_kw"] = new_value
	res["kavua_with_maam"] = kavua + (kavua * GlobalCalcDb.MAAM)
	res["days_passed"] = days_passed
	res["category"] = selected_tab
	res["custom_price_per_100_kw"] = every_kw
	res["custom_price_per_100_kw_with_maam"] = every_kw + (every_kw*GlobalCalcDb.MAAM)
	res["electric_data"] = electric_data.duplicate(true)
	
	if with_maam:
		res["tot_pay"] = res["pay_for_kw_with_maam"] + res["kavua_with_maam"]
	else:
		res["tot_pay"] = res["pay_for_kw"] + res["kavua"]
	
	return res
func _on_custom_kotash_price_on_value_submited(value: Variant) -> void:
	GlobalLoader.SetCustomPricePer100KW(float(value))


func _on_show_history_btn_press() -> void:
	GlobalSignals.BottomTabSelectedStr.emit("HistoryTab")
