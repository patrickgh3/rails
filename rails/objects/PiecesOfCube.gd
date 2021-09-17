extends Spatial

class_name PiecesOfCube

onready var head = $HEAD
onready var arms = $ARM
onready var torso = $TORSO
onready var legs = $LEG
onready var shoes = $SHOES


func _ready():
	# load your image.
	var image = load("res://pretty.png")
	# Get the 3D model
	var mesh = get_node("FaceQuad")
	# Get the material in slot 0
	var material_one = mesh.get_surface_material(0)
	# Change the texture
	material_one.albedo_texture = image
	# Reassign the material
	mesh.set_surface_material(0, material_one)


func crouch():
	head.translation = Vector3(0, -.95, 0)
	arms.hide()
	torso.hide()
	legs.translation = Vector3(0, 0, -.2)
	shoes.translation = Vector3(0, 0, -.2)
	
func stand_up():
	head.translation = Vector3.ZERO
	arms.show()
	torso.show()
	legs.translation = Vector3.ZERO
	shoes.translation = Vector3.ZERO
