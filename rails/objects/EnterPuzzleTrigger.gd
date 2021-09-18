extends Spatial

func _on_Area_body_entered(body):
	if body is Cubio:
		body.register_puzzle(self)
	hide()
