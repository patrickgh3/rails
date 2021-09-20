extends Spatial

const OPEN_Z = PI / 2


onready var controller = $"../Controller"

var opening = false
var t = 0

func _ready():
	rotation.z = 0

func _process(delta):
	if opening:
		t += delta * .1
		if t > 1:
			t = 1
			opening = false
			rotation.z = OPEN_Z
		else:
			var z = lerp(0, OPEN_Z, controller.ease_out_quad(t))
			rotation.z = z


func _on_Boss_open_roof():
	opening = true
	t = 0
