extends Spatial
class_name PuzzleRoot

export(bool) var wind = false
export(bool) var root_01_piano = false
export(bool) var root_02_deep = false
export(bool) var root_03_hope = false
export(bool) var melody_01_guitar_echo = false
export(bool) var melody_02_guitar_harmonics = false
export(bool) var melody_03_piano_keys = false
export(bool) var melody_04_bell_arpeggios = false

export(bool) var debug_spawn_here = false

func _ready():
	if debug_spawn_here:
		print("Notice: starting the player at puzzle "+get_parent().name+ " due to PuzzleRoot having debug_spawn_here checkbox set")
		var controller = $"/root/Root/Controller"
		controller.register_puzzle(self)
		controller.reset_puzzle()