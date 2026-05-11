extends VBoxContainer

var history_item = preload("res://scenes/components/history_item.tscn")

@onready var history_list = $HistoryList
var cur_date = {}

func _ready() -> void:
	cur_date = Time.get_datetime_dict_from_system()
	
	$FilterList/Filter_CurYear.text = str(cur_date.year).pad_decimals(0)
	$FilterList/Filter_LastYear.text = str(cur_date.year-1).pad_decimals(0)
	InitHistory()
	for x in $FilterList.get_children():
		if x is Button:
			x.pressed.connect(OnBtnPressed)
	
func OnBtnPressed():
	InitHistory()
	
	
func InitHistory():
	var sum_p_month := 0.0
	var tot_pay_count := 0
	var tot_this_year := 0.0
	ClearAllHistory()
	var history = GlobalLoader.GetHistory()
	
	#Calculate this whole year:
	for x in history:
		if x.has("tot_pay"):
			tot_this_year += x.tot_pay
		elif x.has("last_pay"):
			var p = float(x.last_pay.replace("₪",""))
			tot_this_year += p
	$Panel/VList/HList/VList/sum_p_year.text = "₪"+str(tot_this_year).pad_decimals(2)
	
	#Filter All:
	if $FilterList/Filter_All.button_pressed:
		for x in history:
			var h = history_item.instantiate()
			history_list.add_child(h)
			h.InitItem(x)
			tot_pay_count += 1
	#Filter Cur Year:
	if $FilterList/Filter_CurYear.button_pressed:
		var show_item = false
		for x in history:
			if x.has("last_date"):
				if int(x.last_date.year) == int(cur_date.year):
					show_item = true
			if x.has("to_date"):
				if int(x.to_date.year) == int(cur_date.year):
					show_item = true
			if show_item:
				var h = history_item.instantiate()
				history_list.add_child(h)
				h.InitItem(x)
				tot_pay_count += 1
			show_item = false
	
	#Filter Last Year:
	if $FilterList/Filter_LastYear.button_pressed:
		var show_item = false
		for x in history:
			if x.has("last_date"):
				if int(x.last_date.year) == int(cur_date.year-1):
					show_item = true
			if x.has("to_date"):
				if int(x.to_date.year) == int(cur_date.year-1):
					show_item = true
			if show_item:
				var h = history_item.instantiate()
				history_list.add_child(h)
				h.InitItem(x)
				tot_pay_count += 1
			show_item = false
	$Panel/VList/HList/VList3/pay_count.text = str(tot_pay_count).pad_decimals(0)
	#sum calculation
	if tot_pay_count > 0:
		sum_p_month = tot_this_year / tot_pay_count
	$Panel/VList/HList/VList2/sum_p_month.text = "₪"+str(sum_p_month).pad_decimals(2)
	
func ClearAllHistory():
	for x in history_list.get_children():
		x.queue_free()


func _on_v_list_resized() -> void:
	await get_tree().process_frame
	var max_y = $Panel/VList.get_minimum_size().y
	$Panel.custom_minimum_size.y = max_y + 40
