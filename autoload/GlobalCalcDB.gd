extends Node

const MAAM = 0.18

var home_pay_data = []
var default_pay_data = []
var custom_pay_data = []

func _ready() -> void:
	#התעריפים בתוקף מ-01.01.2026
	home_pay_data.append(
		{"every_kw":54.51, #באגורות לכל קוט"ש
		"kavua_division": #תשלום קבוע - חלוקה (בש"ח)
			{"2_month_base_1_phase":9.87, #לקוח דו חדשי - מונה בסיס חד פאזי
			"2_month_base_3_phase":11.45, #לקוח דו חדשי - מונה בסיס תלת פאזי
			"single_month_customer":155.81}, #לקוח חד חודשי
		"kavua_supply":{ #תשלום קבוע - אספקה (בש"ח)
			"2_month_base_1_phase":14.87, #לקוח דו חדשי - מונה בסיס חד פאזי
			"2_month_base_3_phase":14.80, #לקוח דו חדשי - מונה בסיס תלת פאזי
			"single_month_customer":106.68}, #לקוח חד חודשי
		"capacity":5.19, #בש"ח ל- KVA בשנה
		"last_updated_date":{"year":2026,"month":1,"day":1} #התעריפים בתוקף
		})
		
	default_pay_data.append(
		{"every_kw":54.51, #באגורות לכל קוט"ש
		"kavua_division": #תשלום קבוע - חלוקה (בש"ח)
			{"2_month_base_1_phase":9.87, #לקוח דו חדשי - מונה בסיס חד פאזי
			"2_month_base_3_phase":11.45, #לקוח דו חדשי - מונה בסיס תלת פאזי
			"single_month_customer":155.81}, #לקוח חד חודשי
		"kavua_supply":{ #תשלום קבוע - אספקה (בש"ח)
			"2_month_base_1_phase":14.87, #לקוח דו חדשי - מונה בסיס חד פאזי
			"2_month_base_3_phase":14.80, #לקוח דו חדשי - מונה בסיס תלת פאזי
			"single_month_customer":106.68}, #לקוח חד חודשי
		"capacity":5.19, #בש"ח ל- KVA בשנה
		"last_updated_date":{"year":2026,"month":1,"day":1} #התעריפים בתוקף
		})
	custom_pay_data = home_pay_data.duplicate()
	
func GetData(tab_btn:String)->Dictionary:
	match tab_btn:
		"HOUSE":
			return home_pay_data[0]
		"DEFAULT":
			return default_pay_data[0]
		"CUSTOM":
			return custom_pay_data[0]
		_:
			print_debug("Unknown Tab: ",tab_btn)
	return home_pay_data[0]

func CalculateDevition(cur_div:String,cur_type:String,need_to_pay:float,from_date:Dictionary,to_date:Dictionary,div_data :Dictionary)->float:
	var to_pay = need_to_pay
	match cur_div:
		"NO_DIVISION":
			return need_to_pay
		"DIV_PART":
			match cur_type:
				"HOUSE":
					var part_div_value = int(div_data["division_part_price"])
					return need_to_pay/ part_div_value
				"DEFAULT":
					var part_div_value = int(div_data["division_part_price"])
					return need_to_pay/ part_div_value
				"CUSTOM":
					var part_div_value = int(div_data["division_part_price"])
					return need_to_pay/ part_div_value
				_:
					print_debug("Unnown Type: ",cur_type)
		"PERCENT":
			match cur_type:
				"HOUSE":
					var percent_div_value = float(div_data["division_percent"])
					return need_to_pay * (percent_div_value/100.0)
				"DEFAULT":
					var percent_div_value = float(div_data["division_percent"])
					return need_to_pay * (percent_div_value/100.0)
				"CUSTOM":
					var percent_div_value = float(div_data["division_percent"])
					return need_to_pay * (percent_div_value/100.0)
		"CUSTOM":
			match cur_type:
				"HOUSE":
					return Global.calculate_payment_by_days(float(div_data["division_custom_price"]),from_date,to_date)
				"DEFAULT":
					return Global.calculate_payment_by_days(float(div_data["division_custom_price"]),from_date,to_date)
				"CUSTOM":
					return Global.calculate_payment_by_days(float(div_data["division_custom_price"]),from_date,to_date)
		_:
			print_debug("Unknown div: ",cur_div)
	return to_pay
