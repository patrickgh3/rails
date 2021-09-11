extends Spatial

var rails = Array()

func _ready():
	# Add all rails to rails array
	for node in self.get_children():
		if "Rail" in node.name:
			rails.append(node)
