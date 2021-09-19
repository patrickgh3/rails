extends Spatial

func _on_Area_body_entered(body):
	if body is Cubio:
		$"/root/Root/Controller".register_puzzle(self.get_parent())
