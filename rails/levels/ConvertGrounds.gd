tool
extends Node

var ran = false

func _process(_delta):
	if Input.is_key_pressed(KEY_K):
		if not ran:
			ran = true
			print("K")
			self.traverse(get_parent())
			
func traverse(node):
	for n in node.get_children():
		if n is Ground:
			print(n.name)
		else:
			traverse(n)
