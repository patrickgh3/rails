extends Spatial



func _ready():
	# load your image.
	var image = load("res://pretty.png")
	# Get the 3D model
	var mesh = get_node("Face")
	# Get the material in slot 0
	var material_one = mesh.get_surface_material(0)
	# Change the texture
	material_one.albedo_texture = image
	# Reassign the material
	mesh.set_surface_material(0, material_one)
