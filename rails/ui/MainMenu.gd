extends Control

func _ready():
	pass


func _on_PlayButton_pressed():
	get_tree().change_scene("res://levels/MainWorld2.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://ui/Credits.tscn")


func _on_ControlsButton_pressed():
	get_tree().change_scene("res://ui/Controls.tscn")
