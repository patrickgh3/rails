extends KinematicBody
# Constant variables for Movement
const SPEED = 5
const GRAVITY = 10
const JUMP = 2
const FALL_MULTY = 0.5
const JUMP_MULTY = 0.9
const CAM_ACCEL = 40
const ACCEL_TYPE = {"default": 10, "air": 4}




const SHAPE_STANDING_Y = .5
const SHAPE_SCALE_STANDING_Y = .95

const SHAPE_CROUCHING_Y = 0
const SHAPE_SCALE_CROUCHING_Y = .45

const CAM_CROUCHING_Y = 0
const CAM_STANDING_Y = 1

const MOUSE_SENSITIVITY = 0.1
const RAY_LENGTH = 1000
onready var camera = $CamRoot/Camera
onready var shape = $CollisionShape
onready var cam_root = $CamRoot
onready var accel = ACCEL_TYPE["default"]


# Strafe leaning
const LEAN_SMOOTH : float = 10.0
const LEAN_MULT : float = 0.066
const LEAN_AMOUNT : float = 0.7

var velocity: Vector3
var dir: Vector3
var gravity_vec = Vector3()
var movement = Vector3()
var currentStrafeDir = 0
var mouse_captured = true
var crouching = false
var highlight 
var debug_marker
var box_hit : Box
var highlight_info
var snap

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	stand_up()
	
	highlight = load("res://objects/Highlight.tscn").instance()
	get_tree().current_scene.call_deferred("add_child", highlight)
	debug_marker = load("res://objects/DebugCube.tscn").instance()
	get_tree().current_scene.call_deferred("add_child", debug_marker)
	highlight_info = load("res://objects/BoxHighlightInfo.gd").new()
	
	
func _process(delta):
	# Press Esc to quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("left_click"):
		try_pull_box()
		
		
	# Camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(cam_root.global_transform.origin, CAM_ACCEL * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = cam_root.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = cam_root.global_transform
		
	#head.rotation.z = lerp(head.rotation.z, currentStrafeDir * LEAN_MULT, delta * LEAN_SMOOTH)
	cam_root.rotation.z = lerp(cam_root.rotation.z, currentStrafeDir * LEAN_MULT, delta * LEAN_SMOOTH)

func _physics_process(delta):
	
	try_highlight_box()


		

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
	else:
		snap = Vector3.DOWN
		accel = ACCEL_TYPE["air"]
		gravity_vec += Vector3.DOWN * GRAVITY * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * JUMP
		if crouching: stand_up()
		
		# 	warning: probably not good to just set positino of the kinematic body now
	if Input.is_action_just_pressed("crouch"):
		if crouching: stand_up()
		else: crouch()
	
	# Moving
	if crouching:
		velocity = velocity.linear_interpolate(dir * SPEED / 4, accel * delta)
	else:
		velocity = velocity.linear_interpolate(dir * SPEED, accel * delta)
	if(gravity_vec > Vector3.ZERO):
		movement = velocity + gravity_vec * JUMP_MULTY
	elif(gravity_vec < Vector3.ZERO):
		movement = velocity + gravity_vec * FALL_MULTY
	else:
		movement = velocity + gravity_vec
	
	# warning-ignore:return_value_discarded
	move_and_slide_with_snap(movement, snap, Vector3.UP)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.get_parent() is Box:
			print ("death by box")



func _input(event):
	if mouse_captured:
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
			
			# Make sure you can't look too far up or down
			$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
			$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
			
			
	if event is InputEventKey:
		if event.scancode == KEY_M and event.is_pressed():
			toggle_cursor ()
				
				
	if event is InputEventKey:
		if event.scancode == KEY_H and event.is_pressed():
			remove_child(highlight)
			get_parent().add_child(highlight)


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
	var center_screen = get_viewport().size / 2
	var from = $CamRoot/Camera.project_ray_origin(center_screen)
	var to = from + $CamRoot/Camera.project_ray_normal(center_screen) * RAY_LENGTH
	var result = space_state.intersect_ray(from, to, [self])
	
	var turn_on_highlight = false
	
	if result:
		debug_marker.translation = result.position
		
		var thing = result.collider.get_parent ()
		
		if thing is Box:
			box_hit = thing as Box
			if box_hit.moving():
				box_hit = null
			else:
				highlight_info = box_hit.get_nearest_face (result.position, (to - from).normalized(), highlight_info)
				if not highlight_info.cool:
					# leave highlight on if it's visible
					turn_on_highlight = highlight.visible
				else:
					highlight.transform.basis = Basis(highlight_info.dirs[0], highlight_info.dirs[1], highlight_info.dirs[2])
					highlight.translation = box_hit.get_world_center() + highlight_info.dirs[2]
					highlight.transform.orthonormalized()
					highlight.scale.x = 2 * highlight_info.dirs[0].length()
					highlight.scale.y = 2 * highlight_info.dirs[1].length()
					turn_on_highlight = true
			
			
	if turn_on_highlight:
		highlight.show()
	else: highlight.hide()

func try_pull_box():
	if box_hit:
		box_hit.face_pulled(highlight_info.face)
		
func stand_up():
	var space_state = get_world().direct_space_state
	var from = shape.global_transform.origin
	var to = shape.global_transform.origin + shape.global_transform.basis.y.normalized() * 1
	var crouch_blocked = space_state.intersect_ray(from, to, [shape])
	
	if not crouch_blocked:
		crouching = false
		cam_root.translation.y = CAM_STANDING_Y
		shape.translation.y = SHAPE_STANDING_Y
		shape.scale.y = SHAPE_SCALE_STANDING_Y
	else:
		print ("crouch was blocked by ", crouch_blocked.collider.name)
		
		
# to be done safely, this is called in physics_process
func crouch():
	crouching = true
	cam_root.translation.y = CAM_CROUCHING_Y
	shape.translation.y = SHAPE_CROUCHING_Y
	shape.scale.y = SHAPE_SCALE_CROUCHING_Y
	
