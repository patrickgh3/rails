tool
extends Node

var ran = false
onready var ground_aligned = load("res://objects/GroundAligned.tscn")

func _process(_delta):
	if Input.is_key_pressed(KEY_K):
		if not ran:
			ran = true
			print("running")
			self.traverse(get_parent())
			
func traverse(node):
	for n in node.get_children():
		if n is Ground:
			
			var root = get_tree().edited_scene_root
			print(root)
			var gnd = load("res://objects/GroundAligned.tscn").instance()
			n.get_parent().add_child(gnd)
			gnd.set_owner(root)
			
			gnd.transform = n.transform
			gnd.scale = n.scale*2
			gnd.translation -= n.scale
			gnd.set_owner(root)
			
			n.queue_free()
		else:
			traverse(n)
