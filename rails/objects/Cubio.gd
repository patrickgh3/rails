extends KinematicBody

const MAX_SPEED = 3
const JUMP_SPEED = 5
const ACCELERATION = 2
const DECELERATION = 4


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
#onready var highlight = $"/root/Root/Highlight"


#onready var camera = $Target/Camera
#onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
#onready var start_position = translation
var velocity: Vector3
var dir: Vector3
var mouse_captured = true
var crouching = false
var highlight 
var box_hit : Box

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	highlight = load("res://objects/Highlight.tscn").instance()
	get_tree().current_scene.call_deferred("add_child", highlight)
	stand_up()
	
	
	
func _process(delta):
	# Press Esc to quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	# warning: probably not good to just set positino of the kinematic body now
	if Input.is_action_just_pressed("crouch"):
		if crouching: stand_up()
		else: crouch()
			
			
	if Input.is_action_just_pressed("left_click"):
		try_pull_box()
		
		

func _physics_process(delta):
	
	try_highlight_box()
	
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = 0
	dir.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	dir = dir.normalized() * MAX_SPEED
	velocity = global_transform.basis.x * dir.x + global_transform.basis.z * dir.z
	#velocity = move_and_slide(velocity, Vector3.UP)
	
	move_and_collide(Vector3.DOWN * 1000)
	move_and_slide(velocity, Vector3.UP)
	
	
#	var target = global_transform.basis.x * dir.x + global_transform.basis.z * dir.z
#	target *= MAX_SPEED
#	var acceleration
#	if dir.dot(hvel) > 0:
#		acceleration = ACCELERATION
#	else:
#		acceleration = DECELERATION

	#hvel = hvel.linear_interpolate(target, acceleration * delta)

	# Assign hvel's values back to velocity, and then move.
	#velocity.x = hvel.x
	#velocity = move_and_slide(velocity, Vector3.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if collision.collider.get_parent() is Box:
			print ("death by box")
		else: print ("I collided with ", collision.collider.name)
	###################
	
#	if Input.is_action_just_pressed("exit"):
#		get_tree().quit()
#	if Input.is_action_just_pressed("reset_position"):
#		translation = start_position

#	var dir = Vector3()
#	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
#	dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	# Get the camera's transform basis, but remove the X rotation such
	# that the Y axis is up and Z is horizontal.
#	var cam_basis = camera.global_transform.basis
#	var basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
#	dir = basis.xform(dir)
#
#	# Limit the input to a length of 1. length_squared is faster to check.
#	if dir.length_squared() > 1:
#		dir /= dir.length()
#
#	# Apply gravity.
#	velocity.y += delta * gravity
#
#	# Using only the horizontal velocity, interpolate towards the input.
#	var hvel = velocity
#	hvel.y = 0

#	var target = dir * MAX_SPEED
#	var acceleration
#	if dir.dot(hvel) > 0:
#		acceleration = ACCELERATION
#	else:
#		acceleration = DECELERATION
#
#	hvel = hvel.linear_interpolate(target, acceleration * delta)
#
#	# Assign hvel's values back to velocity, and then move.
#	velocity.x = hvel.x
#	velocity.z = hvel.z
#	velocity = move_and_slide(velocity, Vector3.UP)
#
#	# Jumping code. is_on_floor() must come after move_and_slide().
#	if is_on_floor() and Input.is_action_pressed("jump"):
#		velocity.y = JUMP_SPEED


#func _on_tcube_body_entered(body):
#	if body == self:
#		get_node("WinText").show()



func _input(event):
	if mouse_captured:
		if event is InputEventMouseMotion:
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
			
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
		var thing = result.collider.get_parent ()
		if thing is Box:
			box_hit = thing as Box
			if not box_hit.moving():
				var dirs = box_hit.get_pull_directions (result.position)
				highlight.translation = box_hit.get_world_center() + dirs[0] * .5 * box_hit.get_scale()
				highlight.transform.basis = Basis(dirs[2], dirs[1], dirs[0])
				highlight.transform.orthonormalized()
				turn_on_highlight = true
			else: box_hit = null
			
		
	if turn_on_highlight:
		highlight.show()
	else: highlight.hide()

func try_pull_box():
	if highlight == null:
		print ("no highlight object")
		return
		
	if box_hit:
		box_hit.was_pulled(highlight.translation)
		
		
func stand_up():
	crouching = false
	cam_root.translation.y = CAM_STANDING_Y
	shape.translation.y = SHAPE_STANDING_Y
	shape.scale.y = SHAPE_SCALE_STANDING_Y
	
func crouch():
	crouching = true
	cam_root.translation.y = CAM_CROUCHING_Y
	shape.translation.y = SHAPE_CROUCHING_Y
	shape.scale.y = SHAPE_SCALE_CROUCHING_Y
