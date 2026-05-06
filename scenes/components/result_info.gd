extends Panel




func UpdateResult(formula:String,result:String):
	$VList/result_bar/HList/formula.text = formula
	$VList/result_bar/HList/tot_kw.text = result
	
func _on_v_list_minimum_size_changed() -> void:
	await get_tree().process_frame
	var y_max = $VList.get_minimum_size().y
	custom_minimum_size.y = y_max+40
