extends Spatial

var boxes = Array()
onready var translation_start = translation
onready var controller = $"../Controller"
var door_t = 0
var skipped = false

func _ready():
	for box in controller.boxes:
		boxes.append(box)
		box.connect("signal_delivered", self, "receive_box_delivered")

func _process(delta):
	# Check if all boxes are delivered
	var all_pressed = true
	for box in boxes:
		if box != null and not box.delivered:
			all_pressed = false
	if skipped: all_pressed = true
	
	# Open and shut door
	var door_t_last = door_t
	if all_pressed:
		door_t += 1 * delta
	else:
		door_t -= 1 * delta
	door_t = clamp(door_t, 0, 1)
	var lerp_t = controller.ease_in_quad(door_t)
	translation.y = translation_start.y + lerp(0, 4, lerp_t)
	
	# Play sound on open
	if door_t_last == 0 and door_t != 0 and all_pressed:
		# Door opening
		$ChimeSound.play()
		$DoorOpenedSound.play()
		$DustParticles.emitting = true
	if door_t == 1 and door_t_last != 1:
		# Door fully opened
		pass
		
	# Play sound on close
	if door_t_last == 1 and door_t != 1:
		# Closing
		$DoorClosedSound.play()
	if door_t == 0 and door_t_last != 0:
		# Door fully closed
		$DustParticles.emitting = true
	
	
# this hears the signal Box.delivered(box, yes)
func receive_box_delivered(box, _yes):
	for i in range(boxes.size()):
		if (boxes[i] == box):
			#print (name, "'s ", box.name, " was delivered: ", yes)
			pass
		
