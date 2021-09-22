extends Spatial

export(bool) var do_dynamic_loading = false


enum PuzzleRegion {OOB, WAREHOUSE, PLATFORMS, LONGJUMP, CLIFFS, STRATOSPHERE}

var current_puzzle = null

var current_region = PuzzleRegion.OOB
var transition_region = PuzzleRegion.OOB
var current_region_scene = null
var transition_region_scene = null

# puzzle region scene holders
var warehouse = null
var platforms = null
var longjump = null
var cliffs = null
var stratosphere = null

var regions = [null, null, null, null, null, null]
var extant_puzzles = []

func _enter_tree():
	# Only really need 23 slots for the 23 puzzles, but what the heck!
	for _n in range(0, 50):
		extant_puzzles.append(null)
	print ("World extant puzzles length ", extant_puzzles.size())

func _ready():
		
	if do_dynamic_loading:
		warehouse = preload("res://regions/Warehouse.tscn")
		platforms = preload("res://regions/Platforms.tscn")
		longjump = preload("res://regions/LongJump.tscn")
		cliffs = preload("res://regions/Cliffs.tscn")
		stratosphere = preload("res://regions/Office.tscn")
		regions[PuzzleRegion.WAREHOUSE] = instance_puzzle_region_scene(PuzzleRegion.WAREHOUSE)



func set_current_puzzle(new_puzzle):
	
	if not do_dynamic_loading:
		return
	
	if current_puzzle == new_puzzle:
		print ("World set same puzzle")
		return
		
	print ("World set puzzle to ", new_puzzle.name)
	current_puzzle = new_puzzle
	
	current_region = current_puzzle.area_num
	transition_region = current_puzzle.area_num + current_puzzle.transition_num
	
	for n in range(0, regions.size()):
		if current_region == n:
			if regions[n] == null:
				print (n, " for current_region, instancing")
				regions[n] = instance_puzzle_region_scene(n)
		elif transition_region == n:
			if regions[n] == null:
				print (n, " for transition_region, instancing")
				regions[n] = instance_puzzle_region_scene(n)
			else: print (n, " transition region already not null")
		elif regions[n] != null:
			print (n, " freeing")
			regions[n].queue_free() 
			regions[n] = null
			
			
	
#	if do_dynamic_loading:
#		var an = current_puzzle.area_num
#		var tn = an + current_puzzle.transition_num
#		for p in puzzles:
#			if p.area_num == an and !p.is_inside_tree():
#				print ("RECHILDING ", p.name, "since part of current area and out of tree")
#				call_deferred("add_child", p)
#			elif p.area_num == tn and !p.is_inside_tree():
#				print ("RECHILDING ", p.name, " since part of transition area and out of tree, rechilding")
#				call_deferred("add_child", p)
#			elif (p.area_num != an  and p.area_num != tn) and p.is_inside_tree():
#				print ("UNCHILDING ", p.name, " since not part of current area or transition area and in tree")
#				call_deferred("remove_child", p)


func instance_puzzle_region_scene(region):
	print ("instance_puzzle_region_scene...")
	var new_scene = null
	match region:
		PuzzleRegion.OOB:
			printerr ("matching OOB???")
			return null
		PuzzleRegion.WAREHOUSE:
			print ("WAREHOUSE")
			new_scene = warehouse.instance()
			continue
		PuzzleRegion.PLATFORMS:
			print ("PLATFORMS")
			new_scene = platforms.instance()
			continue
		PuzzleRegion.LONGJUMP:
			print ("LONGJUMP")
			new_scene = longjump.instance()
			continue
		PuzzleRegion.CLIFFS:
			print ("CLIFFS")
			new_scene = cliffs.instance()
			continue
		PuzzleRegion.STRATOSPHERE:
			print ("STRATOSPHERE")
			new_scene = stratosphere.instance()
			continue
		
	if new_scene != null:
		# Do we need to position them correctly?
		get_tree().current_scene.add_child(new_scene)
		
	
	new_scene.name = str(region)
	
	
	
	return new_scene
	
	
	
	
	
	
	
	
	
	
	
	
	
