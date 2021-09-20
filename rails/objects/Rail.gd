tool
extends Spatial
class_name Rail

export(bool) var is_target = false
export(Material) var usual_material
export(Material) var depth_disable_material
var glow = 0

var attached_to_boss
var current = false

func _ready():
	if get_parent().is_in_group("Boxes"):
		attached_to_boss = get_parent().is_the_boss
	current = true
	set_current_puzzle(false)
	
	# @DEBUG maclark overriding to always use usual_mat
	$MeshInstance.set_surface_material(0, usual_material)

func _process(delta):
	# Pass params to shader
	$MeshInstance.get_surface_material(0).set_shader_param("glow", glow)
	$MeshInstance.get_surface_material(0).set_shader_param("is_target", is_target)
	# Fade out glow
	glow -= delta * glow * 7
	glow = clamp(glow, 0, 1)

func set_current_puzzle(cur):
	if cur != current:
		if current:
			$MeshInstance.set_surface_material(0, usual_material)
		else:
			# @DEBUG maclark overriding to always use usual_mat
			#$MeshInstance.set_surface_material(0, depth_disable_material)
			$MeshInstance.set_surface_material(0, usual_material)
	current = cur
