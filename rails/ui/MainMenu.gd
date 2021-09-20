extends Control

const MAIN_BUTTS_X_PERCENT = .73
const OPTIONS_X_PERCENT = .675

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var _c = get_tree().get_root().connect("size_changed", self, "window_resized")
	
	# Load current audio bus volumes
	$Options/FxVolumeSlider.value = Config.sfx_volume
	$Options/MusicVolumeSlider.value = Config.music_volume
	
	# Load move counter config
	$Options/MoveCounterCheckbox.pressed = Config.show_move_counter
	
	window_resized()


func _on_PlayButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://levels/MainWorld2.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_CreditsButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/Credits.tscn")


func _on_ControlsButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/Controls.tscn")


func _on_FxVolumeSlider_value_changed(value):
	Config.sfx_volume = value


func _on_MusicVolumeSlider_value_changed(value):
	Config.music_volume = value


func _on_MoveCounterCheckbox_toggled(button_pressed):
	Config.show_move_counter = button_pressed

func window_resized():
	print ("Happening!")
	var main_x = get_viewport().size.x * MAIN_BUTTS_X_PERCENT
	$MainButtons.rect_position = Vector2(main_x, $MainButtons.rect_position.y)
	var opt_x = get_viewport().size.x * OPTIONS_X_PERCENT
	$Options.rect_position = Vector2(opt_x, $Options.rect_position.y)

	
	
