extends Node

var rails = Array()
var boxes = Array()
var rails_just_halted = Array()
var rails_just_halted_timer = 0

func _ready():
	for node in $"/root/Root".get_children():
		if "Box" in node.name:
			boxes.append(node)
			
	for rail in get_tree().get_nodes_in_group("Rails"):
		rails.append(rail)
	rails_just_halted = rails.duplicate()
	
	
	var spawn = get_node_or_null("/root/Root/CubioSpawn")
	if not spawn == null:
		spawn.hide()
	
	

func _process(_delta):
	rails_just_halted_timer += 1
	if rails_just_halted_timer == 2:
		rails_just_halted.clear()
		

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_U and event.is_pressed():
			make_cubio()
		
		
func make_cubio():
	var cub = load("res://objects/Cubio.tscn").instance()
	if cub == null:
		print ("no cub")
		cub = load("res://objects/Cubio.tscn").instance()
		
	else:
		print ("found cub ", cub.name)
		
	var spawn = get_node_or_null("/root/Root/CubioSpawn")
	if not spawn == null:
		print ("found spawn")
		cub.translation = spawn.translation
		cub.rotation = spawn.rotation
		spawn.queue_free()
	else:
		print (cub.name, " did not find spawn")
		cub.translation = Vector3.ONE
			
func vectors_equal (a, b, margin = .1):
	return abs(a.x - b.x) < margin and abs(a.y - b.y) < margin and abs(a.z - b.z) < margin	

func ease_out_quad(x):
	return 1 - (1 - x) * (1 - x)
	
func ease_in_quad(x):
	return x * x

