extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Load current audio bus volumes
	$Options/FxVolumeSlider.value = Config.sfx_volume
	$Options/MusicVolumeSlider.value = Config.music_volume
	
	# Load move counter config
	$Options/MoveCounterCheckbox.pressed = Config.show_move_counter


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
