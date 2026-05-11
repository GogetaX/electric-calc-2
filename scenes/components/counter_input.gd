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
			if !Engine.is_editor_hint():
				Global.cur_edit_node = self
			$VList/hint.text = "צריך להיות גבוה יותר"
			$VList/hint.label_color = "PRIMARY"
		"LAST_TIME":
			$VList/title.text = "קריאה קודמת"
			if !Engine.is_editor_hint():
				Global.last_edit_node = self
			$VList/hint.text = "נשלף מהתשלום האחרון"
			$VList/hint.label_color = "NEUTRAL"

func UpdateValues():
	var cur_value = GetValue()
	match tab_type:
		"CURRENT":
			var has_error = false
			if cur_value < Global.last_edit_node.GetValue():
				has_error = true
				
			#If its current tab, check if last tab is lower than current
			if has_error:
				$VList/LineEdit.add_theme_color_override("font_color",Color.RED)
			else:
				$VList/LineEdit.add_theme_color_override("font_color",Color.WHITE)
		"LAST_TIME":
			Global.cur_edit_node.UpdateValues()
	

func _on_line_edit_focus_entered() -> void:
	if !_is_selected:
		_is_selected = true
		$SelectedPanel.self_modulate.a = 0.0
		$SelectedPanel.visible = true
		var t = create_tween()
		t.tween_property($SelectedPanel,"self_modulate:a",1.0,0.1)


func _on_line_edit_focus_exited() -> void:
	if _is_selected:
		UpdateValues()
		_is_selected = false
		var t = create_tween()
		t.tween_property($SelectedPanel,"self_modulate:a",0.0,0.1)
		t.finished.connect(func():$SelectedPanel.visible = false)


func _on_line_edit_format_value_submited(value: String) -> void:
	ValueSubmited.emit(float(value))
	
func GetValue():
	return float($VList/LineEdit.text)
	
func SetInput(input_float:float):
	if int(input_float) == -1:
		$VList/LineEdit.text = "?"
	else:
		$VList/LineEdit.text = str(input_float)
	UpdateValues()


func _on_line_edit_text_changed(_new_text: String) -> void:
	UpdateValues()
