extends Spatial

export(bool) var debug_start_here

func _ready():
	if debug_start_here:
		print("Notice: starting the player at puzzle "+get_parent().name+ " due to CubioSpawn having debug_start_here checkbox set")
		var controller = $"/root/Root/Controller"
		controller.current_puzzle = get_parent()
		controller.reset_puzzle()
