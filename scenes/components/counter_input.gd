@tool
extends Panel

signal ValueSubmited(value:float)

@export_enum("CURRENT","LAST_TIME") var tab_type := "CURRENT":
	set(value):
		tab_type = value
		if is_node_ready():
			_ready()
	get:
		return tab_type
		
var _is_selected = false
		
func _ready() -> void:
	match tab_type:
		"CURRENT":
			$VList/title.text = "קריאה נוכחית"
			$VList/hint.text = "צריך להיות גבוה יותר"
			$VList/hint.label_color = "PRIMARY"
		"LAST_TIME":
			$VList/title.text = "קריאה קודמת"
			$VList/hint.text = "נשלף מהחודש הקודם"
			$VList/hint.label_color = "NEUTRAL"


func _on_line_edit_focus_entered() -> void:
	if !_is_selected:
		_is_selected = true
		$SelectedPanel.self_modulate.a = 0.0
		$SelectedPanel.visible = true
		var t = create_tween()
		t.tween_property($SelectedPanel,"self_modulate:a",1.0,0.1)


func _on_line_edit_focus_exited() -> void:
	if _is_selected:
		_is_selected = false
		var t = create_tween()
		t.tween_property($SelectedPanel,"self_modulate:a",0.0,0.1)
		t.finished.connect(func():$SelectedPanel.visible = false)


func _on_line_edit_format_value_submited(value: String) -> void:
	ValueSubmited.emit(float(value))
	
func GetValue():
	return float($VList/LineEdit.text)
