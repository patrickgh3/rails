extends Spatial

export(bool) var do_dynamic_loading = false

var puzzles = []
var current_puzzle

func add_puzzle(new_puzzle):
	
	var in_puzzles = false
	for p in puzzles:
		if p == new_puzzle: 
			in_puzzles = true
			break
		
	if not in_puzzles:
		print ("added to World: ", new_puzzle.name)
		puzzles.append(new_puzzle)
		
		
func set_current_puzzle(new_puzzle):
	current_puzzle = new_puzzle
	print ("setting World current puzzle: ", current_puzzle.name)
	
	
	if do_dynamic_loading:
		var an = current_puzzle.area_num
		var tn = an + current_puzzle.transition_num
		for p in puzzles:
			if p.area_num == an and !p.is_inside_tree():
				print ("RECHILDING ", p.name, "since part of current area and out of tree")
				call_deferred("add_child", p)
			elif p.area_num == tn and !p.is_inside_tree():
				print ("RECHILDING ", p.name, " since part of transition area and out of tree, rechilding")
				call_deferred("add_child", p)
			elif (p.area_num != an  and p.area_num != tn) and p.is_inside_tree():
				print ("UNCHILDING ", p.name, " since not part of current area or transition area and in tree")
				call_deferred("remove_child", p)
