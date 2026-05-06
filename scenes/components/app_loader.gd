extends Node

func _ready() -> void:
	get_parent().ready.connect(OnParentReady)
	
func OnParentReady():
	GlobalLoader.LoadData()
	GlobalSignals.AppLoaded.emit()
