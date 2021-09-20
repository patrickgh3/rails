extends Control

var old_mouse_mode


const OPTIONS_X_PERCENT = 0.573041
const MARGINS_CONTAINER_X_PERCENT = 0.1722

func _ready():
	
	old_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	get_tree().paused = true

	# Load current audio bus volumes
	$Options/FxVolumeSlider.value = Config.sfx_volume
	$Options/MusicVolumeSlider.value = Config.music_volume
	
	# Load move counter config
	$Options/MoveCounterCheckbox.pressed = Config.show_move_counter
	
	var butt_x = get_viewport().size.x * OPTIONS_X_PERCENT
	$MainButtons.rect_position = Vector2(butt_x, $MainButtons.rect_position.y)
	$Options.rect_position = Vector2(butt_x, $Options.rect_position.y)
	
	var marg_x = get_viewport().size.x * MARGINS_CONTAINER_X_PERCENT
	$MarginContainer.rect_position = Vector2(marg_x, $MarginContainer.rect_position.y)



func _on_PauseMenu_tree_exiting():
	Input.set_mouse_mode(old_mouse_mode)
	get_tree().paused = false


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()


func _on_QuitButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/MainMenu.tscn")


func _on_PlayButton_pressed():
	queue_free()


func _on_FxVolumeSlider_value_changed(value):
	Config.sfx_volume = value


func _on_MusicVolumeSlider_value_changed(value):
	Config.music_volume = value


func _on_MoveCounterCheckbox_toggled(button_pressed):
	Config.show_move_counter = button_pressed
