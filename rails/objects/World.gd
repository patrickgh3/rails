extends Spatial

var rails = Array()

func _ready():
	# Add all rails to rails array
	for node in self.get_children():
		if "Rail" in node.name:
			rails.append(node)

func ease_out_quad(x):
	return 1 - (1 - x) * (1 - x)
	
func ease_in_quad(x):
	return x * x
