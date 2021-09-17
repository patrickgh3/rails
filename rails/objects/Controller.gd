extends Node

var rails = Array()
var boxes = Array()
var grounds = Array()
var rails_just_halted = Array()
var rails_just_halted_timer = 0
var rails_just_departed = Array()
var rails_just_departed_timer = 0

onready var volumes = {}
onready var music_active = {}
onready var rng = RandomNumberGenerator.new()

func _ready():
	
	for node in $"/root/Root".get_children():
		if "Box" in node.name:
			boxes.append(node)
		if "Ground" in node.name:
			grounds.append(node)
			
	for rail in get_tree().get_nodes_in_group("Rails"):
		rails.append(rail)
	rails_just_halted = rails.duplicate()
	
	spawn_cubio_if_no_cubio()
	
	var spawn = get_node_or_null("/root/Root/CubioSpawn")
	if not spawn == null:
		spawn.hide()
	
	volumes[$MusicRoot1Piano] = 0
	volumes[$MusicRoot2Deep] = 0
	volumes[$MusicRoot3Hope] = 0
	volumes[$MusicGuitarEcho] = 0
	music_active[$MusicRoot1Piano] = randf() < 0.5
	music_active[$MusicRoot2Deep] = randf() < 0.5
	music_active[$MusicRoot3Hope] = randf() < 0.5
	music_active[$MusicGuitarEcho] = randf() < 0.5
	
	

func _process(_delta):
	rails_just_halted_timer += 1
	if rails_just_halted_timer == 2:
		rails_just_halted.clear()
	rails_just_departed_timer += 1
	if rails_just_departed_timer == 2:
		rails_just_departed.clear()
		
	# Gradually fade music layers in and out depending on which ones
	# we want to be playing right now
	for node in volumes.keys():
		if music_active[node]:
			volumes[node] += _delta
		else:
			volumes[node] -= _delta
		volumes[node] = clamp(volumes[node], 0, 1)
		node.set_volume_db(lerp(-30, 0, volumes[node]))
	

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
		
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_4:
			music_active[$MusicRoot1Piano] = not music_active[$MusicRoot1Piano]
		if event.scancode == KEY_5:
			music_active[$MusicRoot2Deep] = not music_active[$MusicRoot2Deep]
		if event.scancode == KEY_6:
			music_active[$MusicRoot3Hope] = not music_active[$MusicRoot3Hope]
		if event.scancode == KEY_7:
			music_active[$MusicGuitarEcho] = not music_active[$MusicGuitarEcho]
		if event.scancode == KEY_8:
			for node in volumes.keys():
				music_active[node] = randf() < 0.5

func vectors_equal (a, b, margin = .1):
	return abs(a.x - b.x) < margin and abs(a.y - b.y) < margin and abs(a.z - b.z) < margin	

func ease_out_quad(x):
	return 1 - (1 - x) * (1 - x)
	
func ease_in_quad(x):
	return x * x

