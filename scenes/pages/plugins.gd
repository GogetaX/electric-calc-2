extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.share_plugin = $Share
	match OS.get_name():
		"Android":
			$Admob.att_enabled = false
			$Admob.initialize()
		"iOS":
			$Admob.initialize()


func _on_admob_initialization_completed(_status_data: InitializationStatus) -> void:
	match OS.get_name():
		"Android":
			LoadAds()
		"iOS":
			$Admob.request_tracking_authorization()
	


func _on_admob_banner_ad_loaded(ad_id: AdInfo, _response_info: ResponseInfo) -> void:
	$Admob.show_banner_ad(ad_id)


func _on_admob_app_open_ad_loaded(_ad_id: AdInfo, _response_info: ResponseInfo) -> void:
	$Admob.show_app_open_ad()


func _on_admob_tracking_authorization_denied() -> void:
	LoadAds()


func _on_admob_tracking_authorization_granted() -> void:
	LoadAds()

func LoadAds():
	var request := LoadAdRequest.new()
	if OS.get_name() == "Android":
		request.set_ad_unit_id("ca-app-pub-6225081745698787/8405283791")
	elif OS.get_name() == "iOS":
		request.set_ad_unit_id("ca-app-pub-6225081745698787/2239330690")
	$Admob.load_app_open_ad(request)
	request = LoadAdRequest.new()
	if OS.get_name() == "Android":
		request.set_ad_unit_id("ca-app-pub-6225081745698787/6196931041")
	elif OS.get_name() == "iOS":
		request.set_ad_unit_id("ca-app-pub-6225081745698787/8665099093")
	$Admob.load_banner_ad(request)
