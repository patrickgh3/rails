extends Spatial

var velocity = Vector3()
var edges = Array()
onready var world = owner

var delivered = false

var bumping = false
var bump_t = 0
var bump_dir = Vector3()

func _ready():
	# Bottom
	edges.append({"a": Vector3(0, 0, 0), "b": Vector3(1, 0, 0)})
	edges.append({"a": Vector3(1, 0, 0), "b": Vector3(1, 0, 1)})
	edges.append({"a": Vector3(1, 0, 1), "b": Vector3(0, 0, 1)})
	edges.append({"a": Vector3(0, 0, 1), "b": Vector3(0, 0, 0)})
	
	# Top
	edges.append({"a": Vector3(0, 1, 0), "b": Vector3(1, 1, 0)})
	edges.append({"a": Vector3(1, 1, 0), "b": Vector3(1, 1, 1)})
	edges.append({"a": Vector3(1, 1, 1), "b": Vector3(0, 1, 1)})
	edges.append({"a": Vector3(0, 1, 1), "b": Vector3(0, 1, 0)})
	
	# Sides
	edges.append({"a": Vector3(0, 0, 0), "b": Vector3(0, 1, 0)})
	edges.append({"a": Vector3(0, 0, 1), "b": Vector3(0, 1, 1)})
	edges.append({"a": Vector3(1, 0, 0), "b": Vector3(1, 1, 0)})
	edges.append({"a": Vector3(1, 0, 1), "b": Vector3(1, 1, 1)})

func _process(delta):
	# Test start moving
	var was_still = velocity.x == 0 and velocity.y == 0 and velocity.z == 0
	if velocity.x == 0 and velocity.y == 0 and velocity.z == 0:
		if Input.is_key_pressed(KEY_1):
			velocity.x = -0.5
		if Input.is_key_pressed(KEY_2):
			velocity.x = 0.5
		if Input.is_key_pressed(KEY_3):
			velocity.y = -0.5
		if Input.is_key_pressed(KEY_4):
			velocity.y = 0.5
		if Input.is_key_pressed(KEY_5):
			velocity.z = -0.5
		if Input.is_key_pressed(KEY_6):
			velocity.z = 0.5
	
	# Move
	
	# Accelerate
	velocity += Vector3(sign(velocity.x), sign(velocity.y), sign(velocity.z)) * 5 * delta
	
	# Check if we're about to go off the rails!
	var to_move = velocity * delta
	var result = on_rails(to_move)
	
	if result["valid"]:
		# The place we want to move to is valid, so move there!
		translation += to_move
	else:
		# Start bumping state if we are at a standstill
		if was_still:
			bumping = true
			bump_t = 0
			bump_dir = Vector3(sign(velocity.x), sign(velocity.y), sign(velocity.z))
		
		# Stop
		velocity = Vector3()
		
		# Snap position to the nearest cell (hack, this doesn't support off-grid rails)
		translation.x = round(translation.x)
		translation.y = round(translation.y)
		translation.z = round(translation.z)
	
	
	# Iterate through rails we're touching to do some logic
	
	# If we just tried to do an invalid move, use the current position for glow purposes
	if not result["valid"]:
		result = on_rails(Vector3())
	
	delivered = false
	for rail in result["rails"]:
		# Mark rail pressed, and add to glow
		rail.glow += delta * 10
		rail.glow = min(rail.glow, 1)
		
		# Mark ourselves as delivered, if this rail is a target and we're still
		if rail.is_target and velocity.x == 0 and velocity.y == 0 and velocity.z == 0:
			delivered = true
	
	
	# Bumping state - make the mesh do a little bump in the direction
	# we failed to move in
	if bumping:
		bump_t += delta * 3
		if bump_t > 1:
			bump_t = 1
			bumping = false
		var bump_dist = lerp(0.06, 0, world.ease_out_quad(bump_t))
		$MeshInstance.translation = Vector3(0.5, 0.5, 0.5) + bump_dist * bump_dir



# A box is defined to be on the rails if it has at least 1 edge where both vertices are on any rail.
func on_rails(to_move):
	var valid = false
	var rails = {} # Use a dictionary for rails instead of an array to prevent duplicate entries
	
	# Only check nearby rails, for performance which I think will become a problem
	# once we have hundreds of rails.
	# Note: it's very possible this optimization isn't good enough or has failure cases!
	var nearby_rails = Array()
	for rail in world.rails:
		if rail_nearby(rail):
			nearby_rails.append(rail)
	
	for edge in edges:
		var a = false
		var b = false
		var c = false
		for rail in nearby_rails:
			
			var result = point_on_rail(translation + to_move + edge["a"], rail)
			if result["on"]:
				a = true
				if not result["barely"]: rails[rail] = true

			result = point_on_rail(translation + to_move + edge["b"], rail)
			if result["on"]:
				b = true
				if not result["barely"]: rails[rail] = true
			
			# Check midpoint (kind of hacky)
			result = point_on_rail(translation + to_move + lerp(edge["a"], edge["b"], 0.5), rail)
			if result["on"]:
				c = true
				if not result["barely"]: rails[rail] = true
					
		# All 3 points on this edge must be on a rail for it to be a valid position
		if a and b and c:
			valid = true
			
	return {"valid": valid, "rails": rails.keys()}


# Rough check if the rail is closeby on the grid
func rail_nearby(rail):
	var cutoff = 1
	if abs(round(translation.x) - round(rail.translation.x)) > cutoff: return false
	if abs(round(translation.y) - round(rail.translation.y)) > cutoff: return false
	if abs(round(translation.z) - round(rail.translation.z)) > cutoff: return false
	return true


func point_on_rail(point, rail):
	var line_a = rail.translation
	# We get the basis here to account for the rails being rotated in the scene editor
	var line_b = rail.translation + rail.transform.basis.x.normalized()
	
	# This formula is from: https://stackoverflow.com/a/17590923/2134837
	var ab = (line_a - line_b).length()
	var ap = (point - line_a).length()
	var pb = (point - line_b).length()
	var difference = abs(ab - (ap + pb))
	# Note: epsilon of 0.001 here was chosen pretty arbitrarily
	var on = difference < 0.001
	var barely = (ap < 0.001) != (pb < 0.001)
	return {"on": on, "barely": barely}
