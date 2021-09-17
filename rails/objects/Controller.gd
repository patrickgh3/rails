extends Node

var rails = Array()
var boxes = Array()
var rails_just_halted = Array()
var rails_just_halted_timer = 0
var rails_just_departed = Array()
var rails_just_departed_timer = 0

onready var music1 = $Music1
onready var music2 = $Music2
var music_fade = 0

func _ready():
	
	for node in $"/root/Root".get_children():
		if "Box" in node.name:
			boxes.append(node)
			
	for rail in get_tree().get_nodes_in_group("Rails"):
		rails.append(rail)
	rails_just_halted = rails.duplicate()
	
	spawn_cubio_if_no_cubio()
	
	var spawn = get_node_or_null("/root/Root/CubioSpawn")
	if not spawn == null:
		spawn.hide()
		
	music2.set_volume_db(-100)
	
	

func _process(_delta):
	rails_just_halted_timer += 1
	if rails_just_halted_timer == 2:
		rails_just_halted.clear()
	rails_just_departed_timer += 1
	if rails_just_departed_timer == 2:
		rails_just_departed.clear()
		
	# Fade in and out music
	if Input.is_key_pressed(KEY_U):
		music_fade += _delta
	else:
		music_fade -= _delta
	music_fade = clamp(music_fade, 0, 1)
	#music1.set_volume_db(lerp(-20, 0, music_fade))
	music2.set_volume_db(lerp(-30, 0, music_fade))

func spawn_cubio_if_no_cubio():
	var cub = get_node_or_null("../Cubio")
	var player = get_node_or_null("../Player")
	if cub == null and player == null:
		print ("no cubio or player, making cubio")
		cub = load("res://player/Cubio.tscn").instance()
		get_tree().current_scene.call_deferred("add_child", cub)
	
	var spawn = get_node_or_null("../CubioSpawn")
	if not spawn == null and not cub == null:
		cub.translation = spawn.translation
		cub.rotation = spawn.rotation
		spawn.queue_free()
			
func vectors_equal (a, b, margin = .1):
	return abs(a.x - b.x) < margin and abs(a.y - b.y) < margin and abs(a.z - b.z) < margin	

func ease_out_quad(x):
	return 1 - (1 - x) * (1 - x)
	
func ease_in_quad(x):
	return x * x

