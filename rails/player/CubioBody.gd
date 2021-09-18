extends Spatial

onready var faces = $faces
onready var arms = $ARM
onready var torso = $TORSO
onready var legs = $LEG
onready var shoes = $SHOES


func crouch():
	faces.translation = Vector3(0, 0.503, .03)
	arms.hide()
	torso.hide()
	legs.translation = Vector3(0, 0, -.2)
	shoes.translation = Vector3(0, 0, -.2)
	
func stand_up():
	faces.translation = Vector3(0, 1.453, 0)
	arms.show()
	torso.show()
	legs.translation = Vector3.ZERO
	shoes.translation = Vector3.ZERO
