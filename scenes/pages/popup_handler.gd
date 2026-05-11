extends Control

@onready var app_update = preload("res://scenes/pages/app_update.tscn")

const BLUR_AMOUNT = 3.56
const MIX_AMOUNT = 0.56

func _ready() -> void:
	GlobalSignals.HideCurPopup.connect(OnHideCurPopup)
	GlobalSignals.ShowPopup.connect(OnShowPopup)
	$ColorRect.material.set_shader_parameter("blur_amount",0.0)
	$ColorRect.material.set_shader_parameter("mix_amount",0.0)
	GlobalBtn.AddBtnPress($ColorRect)
	GlobalBtn.BtnPress.connect(OnBtnPress)
	GlobalSignals.AppLoaded.connect(OnAppLoaded)
	visible = false
	

func OnAppLoaded():
	if GlobalLoader.old_data_imported:
		ShowAppUpdatePopup()

func OnBtnPress(btn_control:Control):
	if btn_control != $ColorRect:
		return
	GlobalSignals.HideCurPopup.emit()
	
func OnShowPopup(popup_name:String,data:Dictionary):
	var p = null
	match popup_name:
		"KAVUA_CALC":
			p = load("res://scenes/pages/kavua_settings_popup.tscn").instantiate()
		"DISPLAY_RECEPIE":
			p = load("res://scenes/pages/RecepiePopup.tscn").instantiate()
	
	if p == null:
		print_debug("Unknown popup: ",popup_name)
	else:
		visible = true
		p.modulate.a = 0.0
		$PopupContainer.add_child(p)
		p.InitData(data)
		var t = create_tween()
		t.tween_property(p,"modulate:a",1.0,0.1)
		t.parallel().tween_method(AnimateBlurOff,0.0,BLUR_AMOUNT,0.2)
		t.parallel().tween_method(AnimateMixOff,0.0,MIX_AMOUNT,0.2)
		
func ShowAppUpdatePopup():
	visible = true
	var p = app_update.instantiate()
	p.modulate.a = 0.0
	$PopupContainer.add_child(p)
	var t = create_tween()
	t.tween_property(p,"modulate:a",1.0,0.1)
	t.parallel().tween_method(AnimateBlurOff,0.0,BLUR_AMOUNT,0.2)
	t.parallel().tween_method(AnimateMixOff,0.0,MIX_AMOUNT,0.2)
	
func OnHideCurPopup():
	var t = create_tween()
	for x in $PopupContainer.get_children():
		t.parallel().tween_property(x,"modulate:a",0.0,0.2)
		t.parallel().tween_method(AnimateBlurOff,BLUR_AMOUNT,0.0,0.2)
		t.parallel().tween_method(AnimateMixOff,MIX_AMOUNT,0.0,0.2)
	t.finished.connect(func():visible = false)
		
func AnimateBlurOff(value):
	$ColorRect.material.set_shader_parameter("blur_amount",value)

func AnimateMixOff(value):
	$ColorRect.material.set_shader_parameter("mix_amount",value)
