extends KinematicBody

class_name Boss

# Constant variables for Movement
const SPEED = 5
const GRAVITY = 50
const JUMP = 5
const FALL_MULTY = 0.5
const JUMP_MULTY = 0.9
const ACCEL_TYPE = {"default": 10, "air": 4, "launched": .25}


const SHAPE_STANDING_Y = .5
const SHAPE_SCALE_STANDING_Y = .95
const SHAPE_CROUCHING_Y = 0
const SHAPE_SCALE_CROUCHING_Y = .45


onready var shape = $CollisionShape
onready var body = $BossBody
onready var accel = ACCEL_TYPE["default"]
onready var controller = $"/root/Root/Controller"


var velocity: Vector3
var dir: Vector3
var gravity_vec = Vector3()
var movement = Vector3()
var crouching = false
var debug_marker
var debug_marker1
var snap
var launched
var hit_launch_pad
var launch_box
var launch_box_offset
var my_box


func _ready():
	stand_up()
	add_to_group("Boss")
	
	debug_marker = load("res://objects/DebugCube.tscn").instance()
	debug_marker1 = load("res://objects/DebugCube.tscn").instance()
	debug_marker.hide() # @DEBUG, hidden for release
	debug_marker1.hide() # @DEBUG, hidden for release
	get_tree().current_scene.call_deferred("add_child", debug_marker)
	get_tree().current_scene.call_deferred("add_child", debug_marker1)
	
	
func _process(delta):
	
	if not launch_box == null:
		translation = launch_box.translation + launch_box_offset
		
	if not my_box == null:
		translation = my_box.get_world_center()
		


func _physics_process(delta):
		
	# Jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_TYPE["default"]
		gravity_vec = Vector3.ZERO
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
	if launch_box == null:
		move_and_slide_with_snap(movement, snap, Vector3.UP)

		
func stand_up():
	var space_state = get_world().direct_space_state
	var from = shape.global_transform.origin
	var to = shape.global_transform.origin + shape.global_transform.basis.y.normalized() * 1
	var head_space_blocked = space_state.intersect_ray(from, to, [shape])
	
	if head_space_blocked:
		print ("standing up was blocked by ", head_space_blocked.collider.name)
	else:
		crouching = false
		shape.translation.y = SHAPE_STANDING_Y
		shape.scale.y = SHAPE_SCALE_STANDING_Y
		body.stand_up()
	
		
func crouch():
	crouching = true
	body.crouch()
	
	shape.translation.y = SHAPE_CROUCHING_Y
	shape.scale.y = SHAPE_SCALE_CROUCHING_Y
	
	
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
	velocity = Vector3.FORWARD * 100
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
	my_box.become_human(Vector3(0, y_rad,0))
	translation = my_box.get_world_center()
	controller.boxes.append(my_box)
	$CollisionShape.disabled = true
	crouch()
	body.hide()
	
func unbox():
	if not my_box == null:
		my_box.become_box()
		controller.boxes.erase(my_box)
		translation = my_box.get_world_center() + Vector3.UP * 2
		my_box.hide()
		my_box.queue_free()
	
	body.show()
	stand_up()
	$CollisionShape.disabled = false
	my_box = null