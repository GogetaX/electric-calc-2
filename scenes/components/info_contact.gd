extends Panel

func _ready() -> void:
	await get_tree().process_frame
	_on_v_list_resized()
	
func _on_v_list_resized() -> void:
	await get_tree().process_frame
	var max_y = $VList.get_minimum_size().y
	custom_minimum_size.y = max_y + 40
	size.y = custom_minimum_size.y


func _on_icon_on_press() -> void:
	open_email_contact()

func open_email_contact() -> void:
	var email := "gogetax2@gmail.com"
	var subject := "פנייה מתוך האפליקציה"
	var body := "שלום,\n\nאני רוצה להציע / לשנות / לדווח על:\n\n"

	var mailto := "mailto:%s?subject=%s&body=%s" % [
		email,
		subject.uri_encode(),
		body.uri_encode()
	]

	OS.shell_open(mailto)
