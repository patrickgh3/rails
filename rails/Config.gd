extends Node

var sfx_volume = -6 setget set_sfx_volume
var music_volume = -6 setget set_music_volume
var show_move_counter = false setget set_show_move_counter

func _ready():
	pass


func set_sfx_volume(value):
	sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Sfx'), value)
	if value <= -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Sfx'), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Sfx'), false)


func set_music_volume(value):
	music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Music'), value)
	if value <= -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Music'), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Music'), false)


func set_show_move_counter(value):
	show_move_counter = value


func show_move_counter_ui():
	var scene = get_tree().current_scene
	if scene.find_node("MovesLabel"):
		scene.find_node("MovesLabel").visible = Config.show_move_counter
		scene.find_node("TotalMovesLabel").visible = Config.show_move_counter
