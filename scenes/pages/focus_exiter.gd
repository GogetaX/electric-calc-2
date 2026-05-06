extends Control

func _ready() -> void:
	visible = true
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == 1:
			var focus_owner = get_viewport().gui_get_focus_owner()
			if focus_owner:
				get_viewport().gui_release_focus()
				
