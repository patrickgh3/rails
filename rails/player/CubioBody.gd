extends Spatial

onready var faces = $faces
onready var arms = $ARM
onready var torso = $TORSO
onready var legs = $LEG
onready var shoes = $SHOES

var in_first = true

func crouch():
	if in_first:
		faces.hide()
		legs.hide()
	else:
		faces.show()
		
	shoes.show()
	arms.hide()
	torso.hide()
	
	faces.translation = Vector3(0, 0.503, .03)
	legs.translation = Vector3(0, 0, -.2)
	shoes.translation = Vector3(0, 0, -.2)
	
func stand_up():
	if in_first:
		faces.hide()
		arms.hide()
		torso.hide()
		legs.hide()
	else:
		faces.show()
		arms.show()
		torso.show()
		legs.show()
		
	shoes.show()
	
	faces.translation = Vector3(0, 1.453, 0)
	legs.translation = Vector3.ZERO
	shoes.translation = Vector3.ZERO


func first_person():
	in_first = true
	faces.hide()
	arms.hide()
	torso.hide()
	legs.hide()
	
func third_person():
	in_first = false
	faces.show()
	arms.show()
	torso.show()
	legs.show()
