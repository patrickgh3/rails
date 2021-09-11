extends Spatial

const MOUSE_SENSITIVITY = 0.1

onready var camera = $CamRoot/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)




func _process(delta):
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

func _input(event):
	if event is InputEventMouseMotion:
		$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
