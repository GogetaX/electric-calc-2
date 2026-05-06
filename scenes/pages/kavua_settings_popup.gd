extends Panel

var cur_data = {}

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
			SetSelectedTab(house_settings.phase_type)
			SetSelectedDevisionTab(house_settings.division_data)
			print(house_settings)
	UpdateTabData()
	UpdateDevision()

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

func GetCurSelectedTabData():
	for x :TaarifTabClass in $VList/CustomerTypeContainer.get_children():
		if x.IsSelected():
			return x.setting_name
	return "2_month_base_1_phase"
func SetSelectedTab(tab_name:String):
	for x in $VList/CustomerTypeContainer.get_children():
		x.SetAsUnSelected()
	
	match tab_name:
		"ONE_PHASE_2_MONTH":
			$VList/CustomerTypeContainer/TwoMonthOnePhase.SetAsSelected()
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
	
