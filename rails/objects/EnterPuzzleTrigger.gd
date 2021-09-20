extends Spatial

func _ready():
	hide()
	
onready var controller = $"/root/Root/Controller"

func _on_Area_body_entered(body):
	if body is Cubio:
		controller.register_puzzle(self.get_parent())
