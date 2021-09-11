extends Spatial

var glow = 0

func _process(delta):
	# Pass glow param to shader
	$MeshInstance.get_surface_material(0).set_shader_param("glow", glow)
	
	# Fade out glow
	glow -= delta * glow * 7
	glow = clamp(glow, 0, 1)
