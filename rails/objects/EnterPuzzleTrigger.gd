extends Spatial

onready var controller = $"/root/Root/Controller"
var do_transition



func _ready():
	add_to_group("Hidden")
	hide()
	
	
func _on_Area_body_entered(body):
	if body is Cubio:
		do_transition = true


func _physics_process(_delta):
	if do_transition:
		do_transition = false
		var puzzle = get_parent()
		controller.register_puzzle(puzzle)
