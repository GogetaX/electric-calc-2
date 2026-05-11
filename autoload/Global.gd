extends Node

const SECONDS_PER_DAY := 86400
const SHARED_FILE_PATH = "user://electric_calc.png"

var has_hebrew_month = ""

var cur_edit_node = null
var last_edit_node = null

var share_plugin :Share = null


func calculate_payment_by_days(monthly_payment: float, from_date: Dictionary, to_date: Dictionary) -> float:
	var from_unix := Time.get_unix_time_from_datetime_dict({
		"year": int(from_date.year),
		"month": int(from_date.month),
		"day": int(from_date.day),
		"hour": 0,
		"minute": 0,
		"second": 0
	})

	var to_unix := Time.get_unix_time_from_datetime_dict({
		"year": int(to_date.year),
		"month": int(to_date.month),
		"day": int(to_date.day),
		"hour": 0,
		"minute": 0,
		"second": 0
	})

	var days_passed := int((to_unix - from_unix) / 86400.0)

	var days_in_month := get_days_in_month(
		int(from_date.year),
		int(from_date.month)
	)

	var result := monthly_payment / float(days_in_month) * float(days_passed)
	return snapped(result, 0.01)
	
func GetDaysPassed(from_date: Dictionary, to_date: Dictionary = {}) -> int:
	if to_date.is_empty():
		to_date = Time.get_date_dict_from_system()

	var from_dt := _DateToDateTimeDict(from_date)
	var to_dt := _DateToDateTimeDict(to_date)

	var from_unix := Time.get_unix_time_from_datetime_dict(from_dt)
	var to_unix := Time.get_unix_time_from_datetime_dict(to_dt)

	return max(0, int(floor(float(to_unix - from_unix) / float(SECONDS_PER_DAY))))


func _DateToDateTimeDict(date: Dictionary) -> Dictionary:
	return {
		"year": int(date.get("year", 1970)),
		"month": int(date.get("month", 1)),
		"day": int(date.get("day", 1)),

		# Use noon to avoid edge cases around daylight-saving changes.
		"hour": 12,
		"minute": 0,
		"second": 0
	}
	
func get_days_in_month(year: int, month: int) -> int:
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			if is_leap_year(year):
				return 29
			return 28

	return 30

func is_leap_year(year: int) -> bool:
	return year % 400 == 0 or (year % 4 == 0 and year % 100 != 0)

func date_dict_to_string(d: Dictionary) -> String:
	if not d.has("year") or not d.has("month") or not d.has("day"):
		return ""

	var day := int(d.day)
	var month := int(d.month)
	var year := int(d.year) % 100 # last 2 digits

	var day_str := str(day).pad_zeros(2)
	var month_str := str(month).pad_zeros(2)
	var year_str := str(year).pad_zeros(2)

	return "%s.%s.%s" % [day_str, month_str, year_str]

func DivitionToStr(div_data_dict:Dictionary)->String:
	#division_data: { "type": "NO_DIVISION", "PART_DIV_VALUE": 3, "PERCENT_VALUE": 25, "CUSTOM_PRICE": 50 }
	match div_data_dict.type:
		"NO_DIVISION":
			return "ללא חלוקה"
		"DIV_PART":
			return "חלוקה " + "1/"+str(div_data_dict.PART_DIV_VALUE).pad_decimals(0)
		"PERCENT":
			return "אחוז " + str(div_data_dict.PERCENT_VALUE)+"%"
		"CUSTOM":
			return "קבוע ₪"+str(div_data_dict.CUSTOM_PRICE)
		_:
			print_debug("Unknown div: ",div_data_dict.type)
			return "?"

func KavuaTypeToStr(kavua_type:String)->String:
	match kavua_type:
		"2_month_base_1_phase":
			return "דו חודשי - חד פאזי"
		"2_month_base_3_phase":
			return "דו חודשי - תלת פאזי"
		"single_month_customer":
			return "חד חודשי"
	return "?"

func CategoryToStr(category_type:String)->String:
	match category_type:
		"HOUSE":
			return "ביתי"
		"DEFAULT":
			return "כללי"
		"CUSTOM":
			return "מותאם"
	return "?"

func get_today_hebrew_month_year() -> String:
	var d := Time.get_date_dict_from_system()

	var months := [
		"", # index 0
		"ינואר", "פברואר", "מרץ", "אפריל",
		"מאי", "יוני", "יולי", "אוגוסט",
		"ספטמבר", "אוקטובר", "נובמבר", "דצמבר"
	]

	return "%s %d" % [months[d.month], d.year]

func get_hebrew_month_from_api():
	
	var d := Time.get_date_dict_from_system()

	var url := "https://www.hebcal.com/converter?cfg=json&gy=%d&gm=%d&gd=%d" % [
		d.year, d.month, d.day
	]

	var http := HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(_result, _response_code, _headers, body):
		
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json && json.has("hebrew"):
			Global.has_hebrew_month = json.hebrew
			GlobalSignals.UpdateHebrewMonth.emit()
	)

	http.request(url)

func capture_control(control: Control):
	var window_size = DisplayServer.window_get_size()
	var viewport_size = get_viewport().get_visible_rect().size
	var scale = Vector2(viewport_size.x / window_size.x,viewport_size.y / window_size.y)
	#new method
	#var region = Rect2(control.global_position.x, control.global_position.y, control.size.x, control.size.y)  # change the values around to suit your actual scene
	var region = Rect2(control.global_position.x/scale.x,control.global_position.y/scale.y,control.size.x/scale.x,control.size.y/scale.y)
	var image := get_viewport().get_texture().get_image().get_region(region)
	image.save_png(SHARED_FILE_PATH)
	match OS.get_name():
		"Android","iOS":
			var absolute = OS.get_user_data_dir() + SHARED_FILE_PATH.replace("user://","/")
			print("path: ",absolute)
			share_plugin.share_image(absolute,"חישוב חשמל שלי","","")
	
