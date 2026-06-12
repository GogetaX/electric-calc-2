extends Control

func _ready() -> void:
	match OS.get_name():
		"iOS":
			$HList/custom_label.vertical_alignment = 2 #at bottom
			custom_minimum_size.y = 150
