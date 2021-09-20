tool
extends Spatial

export(String) var message = "Do not jump on boxes." 
export(String) var second_line = ""
export(Vector2) var pos = Vector2(70, 55)
export(bool) var hide_face = false

onready var quad = $Quad
var label : Label

func _ready():
	match_label()
	if hide_face:
		$Sprite3D.hide()

func _process(_delta):
	if Engine.editor_hint:
		match_label()
	else:
		set_process(false)

func match_label():
	if label == null:
		label = find_node(("Label"))
		
	if quad == null:
		quad = $Quad
		
	if quad != null and label != null:
		label.rect_position = pos
		label.text = message
		
		if second_line != "":
			label.text = message + "\n" + second_line
		label.rect_scale = Vector2(.3 / quad.scale.x, .3 / quad.scale.y)
