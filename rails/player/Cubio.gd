extends KinematicBody

class_name Cubio

# Constant variables for Movement
const WALKING_SPEED = 5
const SPRINTING_SPEED = 10
const GRAVITY = 50
const JUMP = 5
const FALL_MULTY = 0.5
const JUMP_MULTY = 0.9
const CAM_ACCEL = 40
const ACCEL_TYPE = {"default": 10, "air": 4, "launched": .25}


const SHAPE_STANDING_Y = .5
const SHAPE_SCALE_STANDING_Y = .95
const SHAPE_CROUCHING_Y = 0
const SHAPE_SCALE_CROUCHING_Y = .45
const CAM_CROUCHING_Y = 0
const CAM_STANDING_Y = 1
const MOUSE_SENSITIVITY = 0.1
const RAY_LENGTH = 18
const CAM_OFFSET3 = Vector3(0, 2, 6)
const CAM_CROUCH_OFFSET3 = Vector3(0, 2, 4)
const CAM_BOX_FORM_OFFSET3 = Vector3(0, .5, 3)
const CAM_OFFSET1 = Vector3(0, 0, 0)



onready var shape = $CollisionShape
onready var cam_root = $CamRoot
onready var camera = $CamRoot/Camera
onready var cubio_body = $CubioBody
onready var accel = ACCEL_TYPE["default"]
onready var controller = $"../Controller"



# Strafe leaning
const LEAN_SMOOTH : float = 10.0
const LEAN_MULT : float = 0.066
const LEAN_AMOUNT : float = 0.7


var self_aware = true # @DEBUG the boss should turn this true?

var boss
var speed = WALKING_SPEED
var velocity: Vector3
var dir: Vector3
var gravity_vec = Vector3()
var movement = Vector3()
var currentStrafeDir = 0
var mouse_captured = true
var crouching = false
var highlight 
var debug_marker
var debug_marker1
var box_hit
var highlight_info
var snap
var first_person
var lean_cam = false # @DEBUG set false for now for max's sake during development
var launched
var hit_launch_pad
var launch_box
var launch_box_offset
var my_box

var camera_offset_t
var target_camera_offset
var transitioning_camera_offset = false
var last_camera_offset
var warping_cam

func _enter_tree():
	add_to_group("Player")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	stand_up()
	first_person_cam()
	
	# Return value isn't used
	var _c = get_tree().get_root().connect("size_changed", self, "window_resized")
	
	highlight = load("res://objects/Highlight.tscn").instance()
	get_tree().current_scene.call_deferred("add_child", highlight)
	
	debug_marker = load("res://objects/DebugCube.tscn").instance()
	debug_marker1 = load("res://objects/DebugCube.tscn").instance()
	debug_marker.hide() # @DEBUG, hidden for release
	debug_marker1.hide() # @DEBUG, hidden for release
	get_tree().current_scene.call_deferred("add_child", debug_marker)
	get_tree().current_scene.call_deferred("add_child", debug_marker1)
	
	highlight_info = load("res://objects/BoxHighlightInfo.gd").new()
	
	for b in get_tree().get_nodes_in_group("Boxes"):
		if b.is_the_boss:
			boss = b
	
	
func _process(delta):
	
	debug_marker.translation = translation
	
	# Press Esc to quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("left_click"):
		try_pull_box(false)
		
	if Input.is_action_just_pressed("right_click"):
		try_pull_box(true)
		
	if first_person:
		# Camera physics interpolation to reduce physics jitter on high refresh-rate monitors
		if Engine.get_frames_per_second() > Engine.iterations_per_second:
			camera.set_as_toplevel(true)
			camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(cam_root.global_transform.origin, CAM_ACCEL * delta)
			camera.rotation.y = rotation.y
			camera.rotation.x = cam_root.rotation.x
		else:
			camera.set_as_toplevel(false)
			camera.global_transform = cam_root.global_transform 
			
		if lean_cam:
			cam_root.rotation.z = lerp(cam_root.rotation.z, currentStrafeDir * LEAN_MULT, delta * LEAN_SMOOTH)
	
	if not launch_box == null:
		translation = launch_box.translation + launch_box_offset
		
	if not my_box == null:
		translation = my_box.get_world_center()
		
		
	#if transitioning_camera_offset:
	if camera.translation != target_camera_offset:
		var cam_lerp_speed = 3
		if warping_cam: cam_lerp_speed = .5
		camera_offset_t += delta * cam_lerp_speed
		if camera_offset_t > 1:
			if warping_cam: print ("Done warping")
			warping_cam = false
			camera_offset_t = 1
			camera.translation = target_camera_offset
		else:
			var y = lerp (last_camera_offset.y, target_camera_offset.y, camera_offset_t)
			var z = lerp (last_camera_offset.z, target_camera_offset.z, camera_offset_t)
			camera.translation = Vector3(0, y, z)
			transitioning_camera_offset = false
			
	# Restart puzzle if you fall too far
	if translation.y < -13:
		controller.reset_puzzle(false)

func _physics_process(delta):
	
	try_highlight_box()
	
		# 	warning: probably not good to just set positino of the kinematic body now
	if Input.is_action_just_pressed("crouch"):
		if crouching: stand_up()
		else: crouch()
	

	# keyboard movement
	dir = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var h_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Check if to lean
	if(h_input < 0):
		currentStrafeDir = LEAN_AMOUNT
	elif(h_input > 0):
		currentStrafeDir = -LEAN_AMOUNT
	else:
		currentStrafeDir = 0
	
	dir = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	
	# Jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_TYPE["default"]
		gravity_vec = Vector3.ZERO
		if launched:
			self_aware = true
			third_person_cam()
			launched = false
	elif launched:
		dir = Vector3.ZERO
		snap = Vector3.DOWN
		accel = ACCEL_TYPE["launched"]
		gravity_vec += Vector3.DOWN * GRAVITY * delta
	else:
		snap = Vector3.DOWN
		accel = ACCEL_TYPE["air"]
		gravity_vec += Vector3.DOWN * GRAVITY * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		do_jump ()
		
	if hit_launch_pad:
		do_launch()
		
	# Moving
	if crouching:
		velocity = velocity.linear_interpolate(dir * speed / 4, accel * delta)
	else:
		velocity = velocity.linear_interpolate(dir * speed, accel * delta)
		
	if(gravity_vec > Vector3.ZERO):
		movement = velocity + gravity_vec * JUMP_MULTY
	elif(gravity_vec < Vector3.ZERO):
		movement = velocity + gravity_vec * FALL_MULTY
	else:
		movement = velocity + gravity_vec
	
	# warning-ignore:return_value_discarded
	if launch_box == null:
		move_and_slide_with_snap(movement, snap, Vector3.UP)


func _input(event):
	if mouse_captured:
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
			# Make sure you can't look too far up or down
			$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
			$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
			
	if event is InputEventKey:
		if event.scancode == KEY_B and event.is_pressed() and self_aware:
			if my_box == null and is_on_floor():
				box_form()
			else:
				if my_box.velocity == Vector3.ZERO:
					unbox()
					
	if event.is_action_pressed("sprint"):
		speed = SPRINTING_SPEED
	elif event.is_action_released("sprint"):
		speed = WALKING_SPEED
					
	
	if event is InputEventKey:
		if event.scancode == KEY_M and event.is_pressed():
			toggle_cursor ()
				
				
	if event is InputEventKey:
		if event.scancode == KEY_H and event.is_pressed():
			remove_child(highlight)
			get_parent().add_child(highlight)
			
	if event is InputEventKey:
		if event.scancode == KEY_3 and event.is_pressed():
			third_person_cam()
			
	if event is InputEventKey:
		if event.scancode == KEY_1 and event.is_pressed():
			first_person_cam()
				
func toggle_cursor ():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true
		
		

func try_highlight_box ():
	
	if highlight == null:
		print ("no highlight object")
		return
	
	var space_state = get_world().direct_space_state
	#var screen_point = get_viewport().size / 2
	var screen_point = ($Sprite as Node2D).position
	
	var from = $CamRoot/Camera.project_ray_origin(screen_point)
	var to = from + $CamRoot/Camera.project_ray_normal(screen_point) * RAY_LENGTH
	var result = space_state.intersect_ray(from, to, [self])
	
	var turn_on_highlight = false
	
	if result:
		#debug_marker.translation = result.position
		var collider_hit = result.collider
		if not collider_hit is Box:
			box_hit = null
		else:
			box_hit = collider_hit as Box
			if box_hit.moving():
				box_hit = null
			else:
				highlight_info = box_hit.get_nearest_face (result.position, (to - from).normalized(), highlight_info)
				if not highlight_info.cool:
					# leave highlight on if it's visible
					turn_on_highlight = highlight.visible
				else:
					highlight.transform.basis = Basis(highlight_info.dirs[0], highlight_info.dirs[1], highlight_info.dirs[2])
					highlight.translation = box_hit.get_world_center_with_bumping() + highlight_info.dirs[2]
					highlight.transform.orthonormalized()
					highlight.scale.x = 2 * highlight_info.dirs[0].length()
					highlight.scale.y = 2 * highlight_info.dirs[1].length()
					turn_on_highlight = true
			
	if turn_on_highlight:
		highlight.show()
	else: highlight.hide()

func try_pull_box(var pull_boss):
	# If any box is moving, don't highlight any box
	for box in controller.boxes:
		if box.velocity != Vector3.ZERO:
			return
	
	if box_hit:
		if pull_boss and not boss == null:
			boss.face_pulled(highlight_info.face)
		else:
			box_hit.face_pulled(highlight_info.face)
		
func stand_up():
	var space_state = get_world().direct_space_state
	var from = shape.global_transform.origin
	var to = shape.global_transform.origin + shape.global_transform.basis.y.normalized() * 1
	var head_space_blocked = space_state.intersect_ray(from, to, [shape])
	
	if head_space_blocked:
		print ("standing up was blocked by ", head_space_blocked.collider.name)
	else:
		crouching = false
		cam_root.translation.y = CAM_STANDING_Y
		shape.translation.y = SHAPE_STANDING_Y
		shape.scale.y = SHAPE_SCALE_STANDING_Y
		cubio_body.stand_up()
		
		var sprite = $Sprite
		var screen_rect = sprite.get_viewport_rect()
		var node = sprite as Node2D
		
		camera_offset_t = 0
		last_camera_offset = camera.translation
		if first_person:
			node.position = Vector2(screen_rect.size.x / 2, screen_rect.size.y / 2)
			target_camera_offset = CAM_OFFSET1
		else:
			node.position = Vector2(screen_rect.size.x / 2, screen_rect.size.y * 3 / 5)
			target_camera_offset = CAM_OFFSET3
			
		transitioning_camera_offset = true
		
		
func crouch():
	crouching = true
	cubio_body.crouch()
	
	cam_root.translation.y = CAM_CROUCHING_Y
	shape.translation.y = SHAPE_CROUCHING_Y
	shape.scale.y = SHAPE_SCALE_CROUCHING_Y
	
	var sprite = $Sprite
	var screen_rect = sprite.get_viewport_rect()
	var node = sprite as Node2D
	
	camera_offset_t = 0
	last_camera_offset = camera.translation
	if not my_box == null:
		node.position = Vector2(screen_rect.size.x / 2, screen_rect.size.y * .625)
		target_camera_offset = CAM_BOX_FORM_OFFSET3
	elif first_person:
		node.position = Vector2(screen_rect.size.x / 2, screen_rect.size.y / 2)
		target_camera_offset = CAM_OFFSET1
	else:
		node.position = Vector2(screen_rect.size.x / 2, screen_rect.size.y * 2 / 3)
		target_camera_offset = CAM_CROUCH_OFFSET3
		
	transitioning_camera_offset = true
	
func third_person_cam():
	first_person = false
	cubio_body.third_person()
	if crouching: crouch()
	else: stand_up()
	
func first_person_cam():
	first_person = true
	cubio_body.first_person()
	if crouching: crouch()
	else: stand_up()
	
func do_jump():
	snap = Vector3.ZERO
	gravity_vec = Vector3.UP * JUMP
	if crouching: stand_up()
	
func do_launch():
	launched = true
	hit_launch_pad = false
	launch_box = null
	snap = Vector3.ZERO
	gravity_vec = Vector3.UP * 50
	velocity = Vector3.LEFT * 100
	if crouching: stand_up()

func try_launch():
	if not launch_box == null:
		hit_launch_pad = true
		

func hit_moving_launchbox(hit_launch_box):
	if not launched and launch_box == null:
		launch_box = hit_launch_box
		launch_box_offset = translation - launch_box.translation
		
		
		
func box_form():
	my_box = load("res://objects/Box.tscn").instance()
	var x = int(floor(translation.x))
	var y = int(floor(translation.y))
	var z = int(floor(translation.z))
	my_box.translation = Vector3(x,y,z) 
	
	var y_rad = atan2(global_transform.basis.z.x, global_transform.basis.z.z)
	
	while y_rad < 0: 
		y_rad += 2 * PI
	
	if y_rad > 7 * PI / 4:
		y_rad = 0
	elif y_rad > 5 * PI / 4:
		y_rad = 3 * PI / 2
	elif y_rad > 3 * PI / 4:
		y_rad = PI
	elif y_rad > PI / 4:
		y_rad = PI / 2
	else:
		y_rad = 0
	
	
	get_tree().current_scene.add_child(my_box)
	my_box.become_human(Vector3(0, y_rad,0), false)
	translation = my_box.get_world_center()
	controller.boxes.append(my_box)
	$CollisionShape.disabled = true
	third_person_cam()
	crouch()
	cubio_body.hide()
	
	
	# Check for box forming ontop of boss
	var space_state = get_world().direct_space_state
	var from = shape.global_transform.origin
	var to = shape.global_transform.origin - shape.global_transform.basis.y.normalized() * 1
	var something_below = space_state.intersect_ray(from, to, [shape])
	if something_below.collider is Box:
		var box_below = something_below.collider as Box
		if box_below.is_the_boss:
			print ("boxformed on boss, added to employees")
			my_box.add_to_group("Employees")
		
	# Check for boxforming on rail that is attached to box
	if not my_box.is_in_group("Employees"):
		my_box.check_for_rail_attached_to_boss()
	
func unbox():
	if not my_box == null:
		my_box.become_box()
		controller.boxes.erase(my_box)
		translation = my_box.get_world_center() + Vector3.UP * 2
		my_box.hide()
		my_box.queue_free()
	
	cubio_body.show()
	third_person_cam()
	stand_up()
	$CollisionShape.disabled = false
	my_box = null
	
func register_puzzle(enter_puzzle_trigger):
	controller.current_puzzle = enter_puzzle_trigger.get_parent()


func window_resized():
	if first_person: first_person_cam()
	else: third_person_cam()


func warp(_with_cam_lerp, new_transform):
	var _old_camera_pos = camera.global_transform.origin
	transform = new_transform
	# Move the player out from in the ground, to avoid stutter for 1 frame
	# This number 0.451 is from inspecting the player's actual y translation
	# in remote view. So it's a hack!
	translation += Vector3.UP * 0.451
	velocity = Vector3.ZERO
	cam_root.rotation_degrees.x = 0

# 	if with_cam_lerp:
#		
#		warping_cam = true
#		camera.global_transform.origin = old_camera_pos
#		debug_marker.translation = 
		
	stand_up()
