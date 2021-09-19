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
onready var master_controller = get_parent().name == "Root"
var current_puzzle = null

func _ready():
	
	#for node in $"/root/Root".get_children():
		#if "Box" in node.name:
		#	boxes.append(node)
		#if "Ground" in node.name:
		#	grounds.append(node)
		
	for box in get_tree().get_nodes_in_group("Boxes"):
		if get_parent().is_a_parent_of(box):
			boxes.append(box)
	
	for rail in get_tree().get_nodes_in_group("Rails"):
		if get_parent().is_a_parent_of(rail):
			rails.append(rail)
	rails_just_halted = rails.duplicate()
	
	#spawn_cubio_if_no_cubio()
	
	if not master_controller:
		var spawn = get_parent().get_node_or_null("CubioSpawn")
		if spawn == null:
			printerr("Spawn not found for controller in this level: "+get_parent().name)
		else:
			spawn.hide()
	
	volumes[$MusicRoot1Piano] = 0
	volumes[$MusicRoot2Deep] = 0
	volumes[$MusicRoot3Hope] = 0
	volumes[$MusicGuitarEcho] = 0
	music_active[$MusicRoot1Piano] = randf() < 0.5
	music_active[$MusicRoot2Deep] = randf() < 0.5
	music_active[$MusicRoot3Hope] = randf() < 0.5
	music_active[$MusicGuitarEcho] = randf() < 0.5
	if not master_controller:
		music_active[$MusicRoot1Piano] = false
		music_active[$MusicRoot2Deep] = false
		music_active[$MusicRoot3Hope] = false
		music_active[$MusicGuitarEcho] = false
	
	

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
		node.set_volume_db(lerp(-50, 0, volumes[node]))
	
	# Skip puzzle button
	if master_controller:
		if Input.is_action_just_pressed("reset_puzzle"):
			reset_puzzle()
		if Input.is_action_just_pressed("skip_puzzle"):
			var door = current_puzzle.get_node("Door")
			if door != null:
				door.skipped = true
			
func reset_puzzle():
	var cubio = get_tree().root.get_node("Root/Cubio")
	var spawn = current_puzzle.get_node("CubioSpawn")
	var controller = current_puzzle.get_node("Controller")
	var door = current_puzzle.get_node("Door")
	
	if door != null:
		door.skipped = false
	cubio.transform = spawn.get_global_transform()
	# Move the player out from in the ground, to avoid stutter for 1 frame
	# This number 0.451 is from inspecting the player's actual y translation
	# in remote view. So it's a hack!
	cubio.translation += Vector3.UP * 0.451
	cubio.velocity = Vector3.ZERO
	cubio.get_node("CamRoot").rotation_degrees.x = 0
	for box in controller.boxes:
		box.reset_transform_to_initial_values()
		box.velocity = Vector3.ZERO
		box.rails_touching.clear()
		
	controller.rails_just_halted = controller.rails.duplicate()

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
		# Debug music keys
		if master_controller:
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

func register_puzzle(enter_puzzle_trigger):
	if current_puzzle != null:
		for rail in current_puzzle.get_node("Controller").rails:
			rail.set_current_puzzle(false)
	current_puzzle = enter_puzzle_trigger.get_parent()
	for rail in current_puzzle.get_node("Controller").rails:
		rail.set_current_puzzle(true)
		
	print(current_puzzle.name)
