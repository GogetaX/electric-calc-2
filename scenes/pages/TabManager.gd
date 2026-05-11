extends ScrollContainer

var calc_page = preload("res://scenes/pages/calc_page.tscn")
var info_page = preload("res://scenes/pages/info_page.tscn")
var how_to_calc_page = preload("res://scenes/pages/how_to_calc.tscn")
var history_page = preload("res://scenes/pages/history_page.tscn")


@onready var margin_container = get_parent() as MarginContainer


func _on_main_tab_btn_pressed() -> void:
	RemoveAndFreeTabs()
	var c = calc_page.instantiate()
	margin_container.add_theme_constant_override("margin_right",0)
	add_child(c)
	c.OnAppLoaded()
	

func RemoveAndFreeTabs():
	for x in get_children():
		x.queue_free()


func _on_info_tab_btn_pressed() -> void:
	RemoveAndFreeTabs()
	var i = info_page.instantiate()
	margin_container.add_theme_constant_override("margin_right",0)
	add_child(i)


func _on_calc_tab_btn_pressed() -> void:
	RemoveAndFreeTabs()
	var h = how_to_calc_page.instantiate()
	margin_container.add_theme_constant_override("margin_right",20)
	add_child(h)


func _on_history_tab_btn_pressed() -> void:
	RemoveAndFreeTabs()
	var h = history_page.instantiate()
	margin_container.add_theme_constant_override("margin_right",20)
	add_child(h)
