extends Spatial

const MOUSE_SENSITIVITY = 0.1
const CROUCHING_Y = .5
const STANDING_Y = 1.3
onready var camera = $CamRoot/Camera



var mouse_captured = true
var ray_length = 1000
var crouching = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# WASD movement
	
	if mouse_captured == true:
		var dir = Vector3()
		if Input.is_action_pressed("ui_left"):
			dir -= camera.global_transform.basis.x
		if Input.is_action_pressed("ui_right"):
			dir += camera.global_transform.basis.x
		if Input.is_action_pressed("ui_up"):
			dir -= camera.global_transform.basis.z
		if Input.is_action_pressed("ui_down"):
			dir += camera.global_transform.basis.z
		
		dir.y = 0
		dir = dir.normalized()
		translation += dir * 5 * delta
	
	# crouching
	if Input.is_action_just_pressed("crouch"):
		if crouching:
			crouching = false
			translation = Vector3(translation.x, STANDING_Y, translation.z)
		else:
			crouching = true
			translation = Vector3(translation.x, CROUCHING_Y, translation.z)
		
	
	# Press Esc to quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
		
		
		
func _physics_process(delta):
	# Raycast to highlight box side potentially
	if Input.is_action_just_pressed("left_click"):
		shoot_ray ()


func _input(event):
	if event is InputEventKey :
		if event.scancode == KEY_M and event.is_pressed():
			toggle_cursor ()
			
	
	
	# Move the mouse to look around
	if mouse_captured:
		if event is InputEventMouseMotion:
			$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
			
			# Make sure you can't look too far up or down
			$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
			


func toggle_cursor ():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true


func shoot_ray ():
	var space_state = get_world().direct_space_state
	var center_screen = get_viewport().size / 2
	var from = $CamRoot/Camera.project_ray_origin(center_screen)
	var to = from + $CamRoot/Camera.project_ray_normal(center_screen) * ray_length
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		var box_hit : Box = result.collider.get_node ("..")
		if box_hit != null:
			box_hit.was_pulled (result.normal)
		else:
			print ("no hit")
	else:
		print ("no result")
