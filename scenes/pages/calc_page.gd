extends VBoxContainer

@onready var history_item = preload("res://scenes/components/history_item.tscn")

var cur_selected_last_month = {}

func _ready() -> void:
	GlobalSignals.AppLoaded.connect(OnAppLoaded)
	GlobalSignals.UpdateValues.connect(OnUpdateValues)
	
func OnAppLoaded():
	ClearAllHistory()
	var history = GlobalLoader.GetHistory()
	for x in history:
		var h = history_item.instantiate()
		$HistoryList.add_child(h)
		h.InitItem(x)
	var closest_month = GlobalLoader.get_closest_last_date_item(GlobalLoader.save_data.history)
	if !closest_month.is_empty():
		cur_selected_last_month = closest_month.get("last_date",Time.get_date_dict_from_system())
	else:
		cur_selected_last_month = Time.get_date_dict_from_system()
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
	UpdateKWCalc()
	
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
			$CustomTab/KotashPrice.value_str = "₪"+str(data.every_kw/100.0)
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
	print("data_to_work_with")
	print(data_to_work_with)
	print("db_data")
	print(db_data)
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
	GlobalSignals.ShowPopup.emit("KAVUA_CALC",{"type":"HOUSE"})


func _on_old_kw_value_submited(_value: float) -> void:
	UpdateKWCalc()


func _on_new_kw_value_submited(_value: float) -> void:
	UpdateKWCalc()
	
func UpdateKWCalc():
	var old_value = $HList/OldKW.GetValue()
	var new_value = $HList/NewKW.GetValue()
	$ResultInfo.UpdateResult(str(new_value)+" - "+str(old_value)+" =",str(new_value-old_value)+" Kwh")
