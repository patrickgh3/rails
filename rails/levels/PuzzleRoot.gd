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

export(bool) var final_level = false

# Track the number of moves used in THIS puzzle
# See Controller for total overall moves in all puzzles
var move_counter = 0

func _ready():
	if debug_spawn_here:
		print("Notice: starting the player at puzzle "+name+ " due to PuzzleRoot having debug_spawn_here checkbox set")
		var controller = $"/root/Root/Controller"
		controller.register_puzzle(self)
		controller.reset_puzzle(false)
		
	if final_level:
		hide_children_final_level(self, true)
			
func hide_children_final_level(node, hide):
	for n in node.get_children():
		if n is Spatial and n.translation.y > 10:
			if hide:
				n.hide()
			else:
				n.show()
		hide_children_final_level(n, hide)
