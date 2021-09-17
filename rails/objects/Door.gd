extends Spatial

export(Array) var boxes
onready var translation_start = translation
onready var controller = $"/root/Root/Controller"
var door_t = 0

func _ready():
	for i in range(boxes.size()):
		boxes[i] = get_node(boxes[i])
		if (boxes[i] == null):
			printerr("null box assigned to door")
			
			
	for box in get_tree().get_nodes_in_group("Boxes"):
		box.connect("delivered", self, "receive_box_delivered")

func _process(delta):
	# Check if all boxes are delivered
	var all_pressed = true
	for box in boxes:
		if box != null and not box.delivered:
			all_pressed = false
	
	# Open and shut door
	if all_pressed:
		door_t += 1 * delta
	else:
		door_t -= 1 * delta
	door_t = clamp(door_t, 0, 1)
	var lerp_t = controller.ease_in_quad(door_t)
	translation.y = translation_start.y + lerp(0, 4, lerp_t)
	
	
# this hears the signal Box.delivered(box, yes)
func receive_box_delivered(box, yes):
	prints ("signal received, box delivered ", box.name, yes)
