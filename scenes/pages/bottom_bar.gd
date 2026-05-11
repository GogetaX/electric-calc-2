extends Control

var banner_height := 0
var vbox_height := 0

func _ready() -> void:
	GlobalSignals.AdjustBottomBar.connect(OnBannerAdjustHeight)

func OnBannerAdjustHeight(new_height:int):
	banner_height = (new_height*2) + 40

func _process(delta: float) -> void:
	if banner_height + vbox_height != custom_minimum_size.y:
		custom_minimum_size.y = int(lerp(float(custom_minimum_size.y),float(banner_height + vbox_height),delta * 10))
		
func _on_h_list_resized() -> void:
	vbox_height = $HList.custom_minimum_size.y + 40
