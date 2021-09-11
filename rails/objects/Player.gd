extends Spatial

const MOUSE_SENSITIVITY = 0.1

onready var camera = $CamRoot/Camera
onready var mouse_captured = true



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# hi

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
	
	
	
	
	
	# Press Esc to quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
		
		
		

func _input(event):
	# Move the mouse to look around
	if event is InputEventMouseMotion and mouse_captured:
		$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		# Make sure you can't look too far up or down
		$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
		
		
	if event is InputEventKey :
		if event.scancode == KEY_M and event.is_pressed():
			_toggle_cursor ()




func _toggle_cursor ():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true
