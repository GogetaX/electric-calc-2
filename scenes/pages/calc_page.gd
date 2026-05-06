extends VBoxContainer

@onready var history_item = preload("res://scenes/components/history_item.tscn")

func _ready() -> void:
	GlobalSignals.AppLoaded.connect(OnAppLoaded)
	
func OnAppLoaded():
	ClearAllHistory()
	var history = GlobalLoader.GetHistory()
	for x in history:
		var h = history_item.instantiate()
		$HistoryList.add_child(h)
		h.InitItem(x)
	
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
	
func SyncSelectedTab():
	$HouseTab.visible = false
	match GlobalLoader.GetCurSelectedTab():
		"HOUSE":
			var data = GlobalCalcDb.GetData(GlobalLoader.GetCurSelectedTab())
			$HouseTab.visible = true
			$HouseTab/KotashPrice.value_str = "₪"+str(data.every_kw/100.0)
			
		_:
			print_debug("Unknown Tab: ",GlobalLoader.GetCurSelectedTab())
			
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
