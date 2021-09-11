extends Spatial

var velocity = Vector3()
onready var world = owner
var edges = Array()

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
	
	pass

func _process(delta):
	# Test start moving
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
	if velocity.x != 0 or velocity.y != 0 or velocity.z != 0:
		# Accelerate
		velocity += Vector3(sign(velocity.x), sign(velocity.y), sign(velocity.z)) * 5 * delta
		
		# Check if we're about to go off the rails!
		var to_move = velocity * delta
		if on_rails(to_move):
			translation += to_move
		else:
			velocity = Vector3()
			# Snap position to the nearest cell (hack, this doesn't support off-grid rails)
			translation.x = round(translation.x)
			translation.y = round(translation.y)
			translation.z = round(translation.z)



# A box is defined to be on the rails if it has at least 1 edge where both endpoints are on a rail.
func on_rails(to_move):
	for edge in edges:
		var a = false
		var b = false
		for rail in world.rails:
			
			# Only check nearby rails, for performance which I think will become a problem
			# once we have hundreds of rails.
			# Note: it's very possible this optimization isn't good enough or has failure cases!
			if not rail_nearby(rail): continue
			
			if not a and point_on_rail(translation + to_move + edge["a"], rail):
				a = true
			if not b and point_on_rail(translation + to_move + edge["b"], rail):
				b = true
			if a and b: break
		if a and b: return true
	return false
	
# Rough check if the rail is closeby on the grid
func rail_nearby(rail):
	var cutoff = 1
	if abs(round(translation.x) - round(rail.translation.x)) > cutoff: return false
	if abs(round(translation.y) - round(rail.translation.y)) > cutoff: return false
	if abs(round(translation.z) - round(rail.translation.z)) > cutoff: return false
	return true

func point_on_rail(point, rail):
	var rail_a = rail.translation
	# We get the basis here to account for the rails being rotated in the scene editor
	var rail_b = rail.translation + rail.transform.basis.x.normalized()
	return point_on_line_segment(point, rail_a, rail_b)

# From: https://stackoverflow.com/a/17590923/2134837
func point_on_line_segment(point, line_a, line_b):
	var ab = (line_a - line_b).length()
	var ap = (point - line_a).length()
	var pb = (point - line_b).length()
	var difference = abs(ab - (ap + pb))
	# Note: epsilon of 0.001 here was chosen pretty arbitrarily!
	return difference < 0.001
