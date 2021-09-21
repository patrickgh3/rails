extends Area

export(bool) var is_scoop = false

var launch_handler
var cubio
var enable_shapes_t = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	var _c = connect("body_entered", self, "on_body_entered")
	var _c1 = connect("body_exited", self, "on_body_exited")
	launch_handler = load("res://objects/LaunchHandler.gd").new()
	
	
func _physics_process(delta):
	if not cubio == null:
		if is_scoop:
			launch_handler.hit_moving_launcher(get_parent(), cubio)
	
	if enable_shapes_t > 0:
		enable_shapes_t -= delta
		if enable_shapes_t <= 0:
			enable_shapes()
			
			#Not needed anymore bc got rid of launch pad
#		else:
#			cubio.try_launch()

func on_body_entered(body):
	if body is Cubio:
		print ("cubio entering launcher")
		cubio = body as Cubio

func on_body_exited(body):
	if body is Cubio:
		print ("cubio exiting launcher")
		cubio = null
		
		
func disable_shapes():
	$CollisionShape.disabled = true
	get_parent().get_node("CollisionShape").disabled = true
	
func enable_shapes():
	$CollisionShape.disabled = false
	get_parent().get_node("CollisionShape").disabled = false
	
func launched_cubio():
	cubio = null
	enable_shapes_t = .25
