extends Spatial

var rails = Array()
var boxes = Array()

func _ready():
	for node in self.get_children():
		if "Box" in node.name:
			boxes.append(node)
			
	for rail in get_tree().get_nodes_in_group("Rails"):
		rails.append(rail)
			
			
func vectors_equal (a, b, margin = .1):
	return abs(a.x - b.x) < margin and abs(a.y - b.y) < margin and abs(a.z - b.z) < margin	

func ease_out_quad(x):
	return 1 - (1 - x) * (1 - x)
	
func ease_in_quad(x):
	return x * x

