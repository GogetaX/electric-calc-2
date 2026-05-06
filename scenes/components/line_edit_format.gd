extends Node

@export_enum("DACIMAL","NUMBER") var text_format = "DACIMAL"

signal ValueSubmited(value:String)

@export_category("DACIMAL")
@export var decimal_min_value = 0.0
@export var decimal_max_value = 0.0
@export var nums_after_dot :int= 1

@export_category("NUMBER")
@export var number_min_value :int = 0
@export var number_max_value :int = 0

var _is_focused = false
var _submited_value = ""

@onready var parent_edit = get_parent() as LineEdit

func _ready() -> void:
	parent_edit.ready.connect(OnParentReady)

func OnParentReady():
	match text_format:
		"DACIMAL":
			parent_edit.virtual_keyboard_type = 3
		"NUMBER":
			parent_edit.virtual_keyboard_type = 2
		_:
			print_debug("Unkpnwn text format: ",text_format)
	parent_edit.focus_entered.connect(IsFocusEntered)
	parent_edit.focus_exited.connect(IsFocusExited)
	_submited_value = parent_edit.text
	
func IsFocusEntered():
	_is_focused = true
	
func IsFocusExited():
	_is_focused = false
	#validate result
	var res = parent_edit.text
	if parent_edit.text == "":
		res = _submited_value
	
	if text_format == "DACIMAL":
		res = str(clampf(float(res),decimal_min_value,decimal_max_value)).pad_decimals(nums_after_dot)
	elif text_format == "NUMBER":
		res = str(clampi(int(res),number_min_value,number_max_value)).pad_decimals(0)
	parent_edit.text = res
	ValueSubmited.emit(res)
	_submited_value = res
	
	
