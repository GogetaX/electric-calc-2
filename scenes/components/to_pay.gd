extends Panel

var max_y_size = 0

var _is_hiden = false

var cur_data = {}

func _ready() -> void:
	$VList/Info.visible = false
	

func _on_v_list_resized() -> void:
	if _is_hiden:
		return
	max_y_size = $VList.get_minimum_size().y + 40
	
func _process(delta: float) -> void:
	if _is_hiden:
		custom_minimum_size.y = lerpf(custom_minimum_size.y,0,10 * delta)
		return
	custom_minimum_size.y = lerpf(custom_minimum_size.y,max_y_size,10 * delta)
	
func SetAsHidden():
	_is_hiden = true
	custom_minimum_size.y = 0.0
	modulate.a = 0.0
	
func AnimateShow():
	var t = create_tween()
	t.tween_property(self,"modulate:a",1.0,0.2)
	_is_hiden = false
	
func AnimateHide():
	if _is_hiden:
		return
	_is_hiden = true
	var t = create_tween()
	t.tween_property(self,"modulate:a",0.0,0.2)

func InitData(data:Dictionary):
	cur_data = data
	#for x in data:
		#print(x,": ",data[x])
		
	$VList/tot_pay.text = "₪" + str(cur_data.tot_pay).pad_decimals(2)
	$VList/Recipe/kw_tot.value_str =  str(cur_data.tot_kw)+' קוט״ש'
	if cur_data.with_maam:
		$VList/Recipe/pay_kw.value_str = "₪" + str(cur_data.pay_for_kw_with_maam).pad_decimals(2)
		$VList/Recipe/pay_kavua.value_str = "₪" + str(cur_data.kavua_with_maam).pad_decimals(2)
		$VList/Recipe/maam.value_str = "כולל"
	else:
		$VList/Recipe/pay_kw.value_str = "₪" + str(cur_data.pay_for_kw).pad_decimals(2)
		$VList/Recipe/pay_kavua.value_str = "₪" + str(cur_data.kavua).pad_decimals(2)
		$VList/Recipe/maam.value_str = "ללא"
	$VList/Recipe/days_passed.value_str = str(cur_data.days_passed).pad_decimals(0)
	$VList/Info/from_to_dates.value_str = Global.date_dict_to_string(cur_data.from_date)+" → "+Global.date_dict_to_string(cur_data.to_date)
	$VList/Info/from_to_kw.value_str = str(cur_data.from_kw).pad_decimals(2)+" → "+str(cur_data.to_kw).pad_decimals(2)
	$VList/Info/haluka_type.value_str = Global.DivitionToStr(cur_data.division_data)
	$VList/Info/haspaka_type.value_str = Global.KavuaTypeToStr(cur_data.phase_type)
	$VList/Info/customer_type.value_str = Global.CategoryToStr(cur_data.category)
	


func _on_expand_retract_on_press() -> void:
	$VList/Info.visible = !$VList/Info.visible
	_on_v_list_resized()


func _on_save_btn_on_press() -> void:
	GlobalLoader.SaveHistory(cur_data)
	AnimateHide()
	GlobalSignals.UpdateHistory.emit()
