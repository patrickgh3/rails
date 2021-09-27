extends Spatial

export(bool) var do_dynamic_loading = false
export(int) var debug_spawn_puzzle_num = 0

var debug = false

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
		stratosphere = preload("res://regions/NewOffice.tscn")
		
		
		if OS.is_debug_build() and debug_spawn_puzzle_num > 0:
			print ("World instancing appropriate regions for puzzle ", debug_spawn_puzzle_num)
			if debug_spawn_puzzle_num == 23:
				regions[PuzzleRegion.STRATOSPHERE] = instance_puzzle_region_scene(PuzzleRegion.STRATOSPHERE)
				regions[PuzzleRegion.CLIFFS] = instance_puzzle_region_scene(PuzzleRegion.CLIFFS)
			elif debug_spawn_puzzle_num == 22:
				regions[PuzzleRegion.STRATOSPHERE] = instance_puzzle_region_scene(PuzzleRegion.STRATOSPHERE)
				regions[PuzzleRegion.CLIFFS] = instance_puzzle_region_scene(PuzzleRegion.CLIFFS)
			elif debug_spawn_puzzle_num >= 20:
				regions[PuzzleRegion.CLIFFS] = instance_puzzle_region_scene(PuzzleRegion.CLIFFS)
				regions[PuzzleRegion.LONGJUMP] = instance_puzzle_region_scene(PuzzleRegion.LONGJUMP)
			elif debug_spawn_puzzle_num >= 10:
				regions[PuzzleRegion.PLATFORMS] = instance_puzzle_region_scene(PuzzleRegion.PLATFORMS)
			else:
				regions[PuzzleRegion.WAREHOUSE] = instance_puzzle_region_scene(PuzzleRegion.WAREHOUSE)
			
			var controller = $Controller
			if controller.master_controller:
				controller.register_puzzle(extant_puzzles[debug_spawn_puzzle_num])
				# Puts player at spawn of next puzzle
				var with_lerp = true
				controller.reset_puzzle(with_lerp)
			else: print ("wtf")
			
		else:
			regions[PuzzleRegion.WAREHOUSE] = instance_puzzle_region_scene(PuzzleRegion.WAREHOUSE)
	
	print ("World is ready")
	
func set_current_puzzle(new_puzzle):
	
	if current_puzzle == new_puzzle:
		print ("World set same puzzle")
		return
		
	print ("World set puzzle to ", new_puzzle.name)
	current_puzzle = new_puzzle
	
	if not do_dynamic_loading:
		return
	
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
		get_tree().current_scene.add_child(new_scene)
	
	return new_scene
	
	
	
	
	
	
	
	
	
	
	
	
	
