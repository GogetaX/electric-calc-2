extends Node

const SECONDS_PER_DAY := 86400


func DictToDateStr(date_dict:Dictionary)->String:
	var res = str(date_dict.get("day",0))+"."+str(date_dict.get("month",0))+"."+str(date_dict.get("year",0))
	return res

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
