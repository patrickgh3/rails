extends Node

var rails = Array()
var boxes = Array()
var grounds = Array()
var rails_just_halted = Array()
var rails_just_halted_timer = 0
var rails_just_departed = Array()
var rails_just_departed_timer = 0

onready var music_players = [
	$wind,
	$root_01_piano,
	$root_02_deep,
	$root_03_hope,
	$melody_01_guitar_echo,
	$melody_02_guitar_harmonics,
	$melody_03_piano,
	]
onready var music_volumes = [0, 0, 0, 0, 0, 0, 0]
onready var music_active = [false, false, false, false, false, false, false]
onready var music_max_db = [0, 0, 0, 0, 0, 0, 0]

onready var rng = RandomNumberGenerator.new()
onready var master_controller = get_parent().name == "Root"
onready var root_puzzle = get_parent()
var current_puzzle = null

func _ready():
		
	for box in get_tree().get_nodes_in_group("Boxes"):
		if get_parent().is_a_parent_of(box):
			boxes.append(box)
	
	for rail in get_tree().get_nodes_in_group("Rails"):
		if get_parent().is_a_parent_of(rail):
			rails.append(rail)
	rails_just_halted = rails.duplicate()
	
	# Verify there is a spawn, and hide it
	if not master_controller:
		var spawn = get_parent().get_node_or_null("CubioSpawn")
		if spawn == null:
			printerr("Spawn not found for controller in this level: "+get_parent().name)
		else:
			spawn.hide()
	
	# Stop music players if not master controller
	if master_controller:
		var i = 0
		for mp in music_players:
			music_max_db[i] = mp.get_volume_db()
			mp.set_volume_db(-80)
			mp.play()
			i += 1
	

func _process(_delta):
	# Rails just halted timers (kinda jank)
	rails_just_halted_timer += 1
	if rails_just_halted_timer == 2:
		rails_just_halted.clear()
	rails_just_departed_timer += 1
	if rails_just_departed_timer == 2:
		rails_just_departed.clear()
	
	# Music logic
	if master_controller:
		for i in range(music_players.size()):
			var mp = music_players[i]
			
			# Update volume
			if music_active[i]: music_volumes[i] += _delta*0.5
			else: music_volumes[i] -= _delta*0.5
			music_volumes[i] = clamp(music_volumes[i], 0, 1)
			
			# Set player volume
			var lerp_t = music_volumes[i]
			# Make the fade out ease, to sound more natural
			lerp_t = 1 - (1 - lerp_t) * (1 - lerp_t)
			lerp_t = 1 - (1 - lerp_t) * (1 - lerp_t)
			var max_db = music_max_db[i]
			mp.set_volume_db(lerp(-80, max_db, lerp_t))
	
	# Reset and skip puzzle buttons
	if master_controller:
		if Input.is_action_just_pressed("reset_puzzle"):
			reset_puzzle()
		if Input.is_action_just_pressed("skip_puzzle"):
			# Open the door
			var door = current_puzzle.get_node("Door")
			if door != null:
				door.skipped = true
			
			# Put you in the next puzzle
			var par = current_puzzle.get_parent()
			var found = false
			for child in par.get_children():
				if child is PuzzleRoot:
					if found:
						register_puzzle(child)
						reset_puzzle()
						break
					if child == current_puzzle:
						found = true
			
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
		
#func _input(event):
##	if event is InputEventKey and event.is_pressed():
##		# Debug music keys
##		if master_controller:
##			if event.scancode == KEY_4:
##				music_active[$MusicRoot1Piano] = not music_active[$MusicRoot1Piano]
##			if event.scancode == KEY_5:
##				music_active[$MusicRoot2Deep] = not music_active[$MusicRoot2Deep]
##			if event.scancode == KEY_6:
##				music_active[$MusicRoot3Hope] = not music_active[$MusicRoot3Hope]
##			if event.scancode == KEY_7:
##				music_active[$MusicGuitarEcho] = not music_active[$MusicGuitarEcho]
##			if event.scancode == KEY_8:
##				for node in volumes.keys():
##					music_active[node] = randf() < 0.5
#	pass

func vectors_equal (a, b, margin = .1):
	return abs(a.x - b.x) < margin and abs(a.y - b.y) < margin and abs(a.z - b.z) < margin	

func ease_out_quad(x):
	return 1 - (1 - x) * (1 - x)

func ease_in_quad(x):
	return x * x

func register_puzzle(new_puzzle):
	if current_puzzle != null:
		for rail in current_puzzle.get_node("Controller").rails:
			rail.set_current_puzzle(false)
	
	current_puzzle = new_puzzle
	
	for rail in current_puzzle.get_node("Controller").rails:
		rail.set_current_puzzle(true)
	
	# Set music flags
	music_active[0] = current_puzzle.wind
	music_active[1] = current_puzzle.root_01_piano
	music_active[2] = current_puzzle.root_02_deep
	music_active[3] = current_puzzle.root_03_hope
	music_active[4] = current_puzzle.melody_01_guitar_echo
	music_active[5] = current_puzzle.melody_02_guitar_harmonics
	music_active[6] = current_puzzle.melody_03_piano_keys
