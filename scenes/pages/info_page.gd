extends VBoxContainer

func _ready() -> void:
	var house_data = GlobalCalcDb.GetData("HOUSE")
	var default_data = GlobalCalcDb.GetData("DEFAULT")

	$info_box_maam.value_str = str(GlobalCalcDb.MAAM*100.0).pad_decimals(0) +"%"
	$info_box_home.value_str = str(house_data.every_kw+(house_data.every_kw*GlobalCalcDb.MAAM)).pad_decimals(2)+" אוגורות"
	$info_box_default.value_str = str(default_data.every_kw+(default_data.every_kw*GlobalCalcDb.MAAM)).pad_decimals(2)+" אוגורות"
	#עודכן לאחרונה: 2024
	$info_box_home.last_update = "עודכן לאחרונה: "+Global.date_dict_to_string(house_data.last_updated_date)
	$info_box_default.last_update = "עודכן לאחרונה: "+Global.date_dict_to_string(default_data.last_updated_date)
	$info_box_maam.last_update = "עודכן לאחרונה: "+Global.date_dict_to_string(GlobalCalcDb.maam_last_update)
