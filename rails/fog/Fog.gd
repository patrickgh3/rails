tool
extends Spatial

export(int,1,50) var length = 1 setget set_length;
export(int,1,50) var width = 1 setget set_width;

var mesh_size = 50

func _ready():
	update_multimesh()


func set_length(value):
	length = value
	update_multimesh()
	
	
func set_width(value):
	width = value
	update_multimesh()
	
	
func update_multimesh():
	if not is_inside_tree():
		return
		
	var instance_count = width * length
	
	$MultiMeshInstance.multimesh.instance_count = instance_count

	var instance = 0
	for x in range(length):
		for z in range(width):
			var origin = Vector3(x * mesh_size - (length * mesh_size)/2.0, 0, z * mesh_size - (width * mesh_size)/2.0)
			var xform = Transform(Vector3.RIGHT, Vector3.UP, Vector3.BACK, origin)
			$MultiMeshInstance.multimesh.set_instance_transform(instance, xform)
			instance += 1
