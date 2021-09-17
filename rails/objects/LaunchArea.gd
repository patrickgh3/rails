extends Area

# Called when the node enters the scene tree for the first time.
func _ready():
	var c = connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if body is Cubio:
		print ("body entered cubio ", body.name)
		var cubio = body as Cubio
		cubio.try_launch()
