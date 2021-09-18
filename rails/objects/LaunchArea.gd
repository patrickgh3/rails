extends Area

export(bool) var is_scoop = false

var launch_handler

# Called when the node enters the scene tree for the first time.
func _ready():
	var _c = connect("body_entered", self, "on_body_entered")
	launch_handler = load("res://objects/LaunchHandler.gd").new()

func on_body_entered(body):
	if body is Cubio:
		var player = body as Cubio
		if is_scoop:
			launch_handler.hit_moving_launcher(get_parent(), player)
		else:
			player.try_launch()
