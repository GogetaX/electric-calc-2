extends Node
const OLD_SAVE_DATA = "user://db.ini"
const OLD_SETTING_DATA = "user://Settings.ini"

const NEW_SAVE_DATA = "user://db_v2.ini"

const DEFAULT_DIVITION_SETTINGS = {"with_maam":true,"division_data":{"type":"NO_DIVISION"},"phase_type":"ONE_PHASE_2_MONTH"}

var save_data = {}

func LoadData():
	if FileAccess.file_exists(NEW_SAVE_DATA):
		LoadDataFromSave()
		return
	save_data = CreateEmptyData()
	if FileAccess.file_exists(OLD_SAVE_DATA):
		ImportDataFromOldFile()
		return
	
func LoadDataFromSave():
	print_debug("TODO: Trying to load data from save")
	
func ImportDataFromOldFile():
	if FileAccess.file_exists(OLD_SAVE_DATA):
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
				var history_data = {"prev_date":{},"last_date":payment_date_dict,"last_pay":pay_total_str,"prev_kw":kw_last,"cur_kw":kw_cur}
				save_data["history"].append(history_data)
		print_debug("TODO: remove file: ",OLD_SAVE_DATA," when finished importing")
	
	if FileAccess.file_exists(OLD_SETTING_DATA):
		var f = FileAccess.open(OLD_SETTING_DATA,FileAccess.READ)
		var s = f.get_var()
		f.close()
		print("settings: ")
		print(s)
		save_data["cur_selected"] = s["e-type"]
		print_debug("TODO: remove file: ",OLD_SETTING_DATA," when finished importing")
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
	res["house_settings"] = DEFAULT_DIVITION_SETTINGS.duplicate()
	res["default_settings"] = DEFAULT_DIVITION_SETTINGS.duplicate()
	res["custom_settings"] = DEFAULT_DIVITION_SETTINGS.duplicate()
	
	return res

func GetHistory():
	return save_data.history

func GetCurSelectedTab():
	return save_data.cur_selected

func SetCurTab(tab_name:String):
	save_data.cur_selected = tab_name
	SyncSave()
	
func SyncSave():
	print_debug("TODO: Save to file: ",NEW_SAVE_DATA)
