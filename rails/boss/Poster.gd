tool
extends Spatial

export(String) var message = "Do not stand on boxes."

var label

func _ready():
	label = find_node("Label")
	label.text = message
	
func _process(delta):
	if Engine.editor_hint:
		if label == null:
			label = find_node(("Label"))
		label.text = message
	else:
		set_process(false)
