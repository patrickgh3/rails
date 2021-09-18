tool
extends Spatial
class_name Rail

export(bool) var is_target = false
var glow = 0

var attached_to_boss

func _ready():
	if get_parent().is_in_group("Boxes"):
		attached_to_boss = get_parent().is_the_boss

func _process(delta):
	# Pass params to shader
	$MeshInstance.get_surface_material(0).set_shader_param("glow", glow)
	$MeshInstance.get_surface_material(0).set_shader_param("is_target", is_target)
	# Fade out glow
	glow -= delta * glow * 7
	glow = clamp(glow, 0, 1)
