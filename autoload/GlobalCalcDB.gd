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
