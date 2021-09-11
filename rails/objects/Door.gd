extends Spatial

export(Array) var boxes
onready var translation_start = translation
onready var world = owner
var door_t = 0

func _ready():
	for i in range(boxes.size()):
		boxes[i] = get_node(boxes[i])

func _process(delta):
	# Check if all boxes are delivered
	var all_pressed = true
	for box in boxes:
		if not box.delivered:
			all_pressed = false
	
	# Open and shut door
	if all_pressed:
		door_t += 1 * delta
	else:
		door_t -= 1 * delta
	door_t = clamp(door_t, 0, 1)
	var lerp_t = world.ease_in_quad(door_t)
	translation.y = translation_start.y + lerp(0, 4, lerp_t)
