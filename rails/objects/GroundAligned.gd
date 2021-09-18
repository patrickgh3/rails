tool
extends Spatial

func _ready():
	$"OffsetSpatial/MeshInstance".get_surface_material(0).set_shader_param("Scale", scale)
