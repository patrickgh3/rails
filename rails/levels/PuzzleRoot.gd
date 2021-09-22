extends Spatial
class_name PuzzleRoot

export(int) var area_num = 0
export(int) var transition_num = 0

export(bool) var wind = false
export(bool) var root_01_piano = false
export(bool) var root_02_deep = false
export(bool) var root_03_hope = false
export(bool) var melody_01_guitar_echo = false
export(bool) var melody_02_guitar_harmonics = false
export(bool) var melody_03_piano_keys = false
export(bool) var melody_04_bell_arpeggios = false
export(bool) var melody_05_bass_riff = false

export(bool) var debug_spawn_here = false

export(bool) var final_level = false

export(bool) var teleport_skip = false

# Track the number of moves used in THIS puzzle
# See Controller for total overall moves in all puzzles
var move_counter = 0
onready var controller = $Controller

func _ready():
	var world = get_node("/root/Root")
	if debug_spawn_here and OS.is_debug_build() and !world.do_dynamic_loading:
		var master_controller = $"/root/Root/Controller"
		print("Notice: starting the player at puzzle " +name+ " due to PuzzleRoot having debug_spawn_here checkbox set")
		master_controller.register_puzzle(self)
		master_controller.reset_puzzle(false)
		
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

func tree_exited():
	print (name, " exited tree")
