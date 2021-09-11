extends Spatial

var rails = Array()

func _ready():
	# Add all rails to rails array
	for node in self.get_children():
		if "Rail" in node.name:
			rails.append(node)
			
			
func vectors_equal (a, b, margin = .1):
	return abs(a.x - b.x) < margin and abs(a.y - b.y) < margin and abs(a.z - b.z) < margin
