extends Node
const OLD_SAVE_DATA = "user://db.ini"
const OLD_SETTING_DATA = "user://Settings.ini"

const NEW_SAVE_DATA = "user://db_v2.ini"

const DEFAULT_DIVITION_SETTINGS = {"with_maam":true,"division_data":{"type":"NO_DIVISION","PART_DIV_VALUE":3,"PERCENT_VALUE":25,"CUSTOM_PRICE":50},"phase_type":"2_month_base_1_phase","custom_price_per_100_kw":-1}

var save_data = {}

var old_data_imported = false

func LoadData():
	save_data = CreateEmptyData()
	if FileAccess.file_exists(NEW_SAVE_DATA):
		LoadDataFromSave()
		return
	
	if FileAccess.file_exists(OLD_SAVE_DATA):
		ImportDataFromOldFile()
		return
	
func LoadDataFromSave():
	var file := FileAccess.open(NEW_SAVE_DATA, FileAccess.READ)
	if file == null:
		push_error("Failed to read save file")
		return
	
	var json_text := file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(json_text)
	
	if typeof(result) != TYPE_DICTIONARY:
		return
	save_data = result
	
func SaveHistory(history_data:Dictionary):
	save_data.history.append(history_data)
	SyncSave()
	
func ImportDataFromOldFile():
	if FileAccess.file_exists(OLD_SAVE_DATA):
		old_data_imported = true
		var f = FileAccess.open(OLD_SAVE_DATA,FileAccess.READ)
		var s = f.get_var()
		f.close()
		for x in s:
			if x.size() == 5:
				var payment_date_str = x[1]
				var kw_last = x[2]
				var pay_total_str = x[3]
				var kw_cur = x[4]
				var payment_date_dict = StrDateToDict(payment_date_str)
				var history_data = {"from_old_save":true,"prev_date":{},"last_date":payment_date_dict,"last_pay":pay_total_str,"prev_kw":kw_last,"cur_kw":kw_cur}
				save_data["history"].append(history_data)
		DirAccess.remove_absolute(OLD_SAVE_DATA)
		
	if FileAccess.file_exists(OLD_SETTING_DATA):
		old_data_imported = true
		var f = FileAccess.open(OLD_SETTING_DATA,FileAccess.READ)
		var s = f.get_var()
		f.close()
		save_data["cur_selected"] = s["e-type"]
		DirAccess.remove_absolute(OLD_SETTING_DATA)
	SyncSave()
	#e-type == "HOUSE","DEFAU:T","CUSTOM"

func StrDateToDict(str_date:String)->Dictionary:
	var ret = Time.get_date_dict_from_system()
	var s = str_date.split(".")
	if s.size()==3:
		if int(s[0]) > 0:
			ret["day"] = int(s[0])
		if int(s[1]) > 0:
			ret["month"] = int(s[1])
		if int(s[2]) > 0:
			ret["year"] = int(s[2])
	return ret
	
func CreateEmptyData():
	var res = {}
	res["history"] = []
	res["cur_selected"] = "HOUSE"
	res["house_settings"] = DEFAULT_DIVITION_SETTINGS.duplicate(true)
	res["default_settings"] = DEFAULT_DIVITION_SETTINGS.duplicate(true)
	res["custom_settings"] = DEFAULT_DIVITION_SETTINGS.duplicate(true)
	
	return res

func GetSettings(data_name:String)->Dictionary:
	match data_name:
		"HOUSE":
			return save_data.house_settings
		"DEFAULT":
			return save_data.default_settings
		"CUSTOM":
			return save_data.custom_settings
		_:
			print_debug("Unknown data name: ",data_name)
			return save_data.house_settings
			
func GetHistory(last_history := -1):
	if last_history == -1:
		var res = []
		for x in range(save_data.history.size()-1,-1,-1):
			res.append(save_data.history[x])
		return res
	else:
		var res = []
		var counter = 0
		for x in range(save_data.history.size()-1,-1,-1):
			res.append(save_data.history[x])
			counter += 1
			if counter >= last_history:
				return res
		return res
func GetCurSelectedTab():
	return save_data.cur_selected

func SetCurTab(tab_name:String):
	save_data.cur_selected = tab_name
	SyncSave()
	
func SyncSave():
	var f = FileAccess.open(NEW_SAVE_DATA,FileAccess.WRITE)
	var json_text = JSON.stringify(save_data,"\t")
	f.store_string(json_text)
	f.close()

func get_closest_last_date_item(items: Array) -> Dictionary:
	if save_data.history.is_empty():
		return Time.get_date_dict_from_system()
	
	var today := Time.get_date_dict_from_system()
	var today_unix := Time.get_unix_time_from_datetime_dict({
		"year": today.year,
		"month": today.month,
		"day": today.day,
		"hour": 0,
		"minute": 0,
		"second": 0
	})

	var closest_item: Dictionary = {}
	var closest_diff := INF

	for item in items:
		if item.has("last_date") || item.has("to_date"):
			var d : Dictionary = Time.get_date_dict_from_system()
			if item.has("last_date"):
				d = item.last_date
			elif item.has("to_date"):
				d = item.to_date

			if not d.has("year") or not d.has("month") or not d.has("day"):
				continue

			var date_unix := Time.get_unix_time_from_datetime_dict({
				"year": int(d.year),
				"month": int(d.month),
				"day": int(d.day),
				"hour": 0,
				"minute": 0,
				"second": 0
			})

			var diff = abs(today_unix - date_unix)

			if diff < closest_diff:
				closest_diff = diff
				closest_item = item
	
	return closest_item

func SetCustomPricePer100KW(price:float):
	save_data.custom_settings.custom_price_per_100_kw = price
	SyncSave()
	
func GetCustomPricePer100KW():
	return save_data.custom_settings.custom_price_per_100_kw
