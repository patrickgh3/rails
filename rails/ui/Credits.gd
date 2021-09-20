extends Control

export(bool) var ending = false

var t = 0

func _ready():
	
	var _c = get_tree().get_root().connect("size_changed", self, "window_resized")
	
	if ending:
		$Panel.rect_position = Vector2.ZERO
		$Panel.rect_size = get_viewport().size

func _process(delta):
	t += delta
	if t > 2:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_BackButton_pressed():
	var _c = get_tree().change_scene("res://ui/MainMenu.tscn")

func window_resized():
	if ending:
		$Panel.rect_position = Vector2.ZERO
		$Panel.rect_size = get_viewport().size
