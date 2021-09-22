extends Spatial

const OPEN_Z = 0
const CLOSED_Z = -PI / 2


onready var controller = $"../Controller"

var opening = false
var t = 0

func _ready():
	rotation.z = CLOSED_Z

func _process(delta):
	
	# NOTE: rails only work as children of non-rotated scenes.
	# Had to orient the roof so that when it's open,
	# it has zero rotation. Alternatively, could unchild the rails
	# and rechild them to Root or something, but that requires
	# an impossible level of intellect, only achieved by
	# true, box-headed programmers. 
	if opening:
		t += delta * .1
		if t > 1:
			t = 1
			opening = false
			rotation.z = OPEN_Z
		else:
			var z = lerp(CLOSED_Z, OPEN_Z, controller.ease_out_quad(t))
			rotation.z = z

func _on_Boss_open_roof():
	opening = true
	t = 0
	$"RoofGround/AudioStreamPlayer".play()


func _on_Area_body_entered(body):
	if body is Cubio:
		opening = true
		t = 0
		$"RoofGround/AudioStreamPlayer".play()
