extends Node

const SECONDS_PER_DAY := 86400


func DictToDateStr(date_dict:Dictionary)->String:
	var res = str(date_dict.get("day",0))+"."+str(date_dict.get("month",0))+"."+str(date_dict.get("year",0))
	return res

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
