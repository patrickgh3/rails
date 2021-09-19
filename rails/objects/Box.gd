extends KinematicBody
class_name Box

const box_speed = 1

onready var controller = $"../Controller"
onready var mesh = $MeshInstance


enum Face {X_PLUS, X_MINUS, Y_PLUS, Y_MINUS, Z_PLUS, Z_MINUS}

signal signal_delivered(box, yes)
signal moved

export(bool) var launcher = false
export(bool) var is_the_boss = false

var velocity = Vector3()
var grab_velocity : Vector3
var edges = Array()
export(bool) var delivered = false
# For boxes which have a target rail directly on one of their edges,
# currently just the one box in MovingTarget puzzle
export(bool) var always_delivered_hack = false


var bumping = false
var bump_t = 0
var bump_dir = Vector3()
var rails_touching = Array()
var rail_volume_1 = 0
var rail_volume_2 = 0
var rail_sound_index = 1
var initial_translation
var initial_rotation
var flesh

func _enter_tree():
	add_to_group("Boxes")

func _ready():
	initial_translation = translation
	initial_rotation = rotation
	

		
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
	
	for edge in edges:
		edge["a"] *= scale
		edge["b"] *= scale
		
	if is_the_boss:
		become_human(Vector3.ZERO, true)
		
		
		

func _process(delta):
	# Apply grab velocity, if it was set
	var was_still = velocity == Vector3.ZERO
	if grab_velocity != Vector3.ZERO:
		velocity = grab_velocity
		grab_velocity = Vector3.ZERO
		
		if rail_sound_index == 1: rail_sound_index = 2
		else: rail_sound_index = 1
		if rail_sound_index == 1:
			$RailSound1.play()
			rail_volume_1 = 0
		else:
			$RailSound2.play()
			rail_volume_2 = 0
			
		for node in get_children():
			if "Rail" in node.name:
				controller.rails_just_departed.append(node)
				controller.rails_just_departed_timer = 0
		
	# Set rail sound volumes
	var volume_delta = delta*10
	if rail_sound_index == 1:
		if velocity != Vector3.ZERO:
			rail_volume_1 += volume_delta
		else:
			rail_volume_1 -= volume_delta
		rail_volume_2 -= volume_delta
	else:
		if velocity != Vector3.ZERO:
			rail_volume_2 += volume_delta
		else:
			rail_volume_2 -= volume_delta
		rail_volume_1 -= volume_delta
	rail_volume_1 = clamp(rail_volume_1, 0, 1)
	rail_volume_2 = clamp(rail_volume_2, 0, 1)
	$RailSound1.max_db = lerp(-100, 3, rail_volume_1)
	$RailSound2.max_db = lerp(-100, 3, rail_volume_2)
	
	# Accelerate
	if velocity != Vector3.ZERO:
		velocity += Vector3(sign(velocity.x), sign(velocity.y), sign(velocity.z)) * 20 * delta
		
		# Check if we're about to go off the rails!
		var to_move = velocity * delta
		var result = on_rails(to_move)
		
		if result["valid"]:
			# The place we want to move to is valid, so move there!
			translation += to_move
			if is_the_boss:
				for b in get_tree().get_nodes_in_group("Employees"):
					# There is employee slipping, however
					b.translation += to_move
			elif is_in_group("Employees"):
				remove_from_group("Employees")
				
		else:
			# Keep travelling by small increments until we are about to leave the rails
			while true:
				result = on_rails(to_move*0.1)
				if not result["valid"]:
					break
				translation += to_move*0.1
			
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

			# If we just tried to do an invalid move, use the current position for glow purposes
			result = on_rails(Vector3())

			for node in get_children():
				if "Rail" in node.name:
					controller.rails_just_halted.append(node)
					controller.rails_just_halted_timer = 0
					
			$StopSound.play()
			$moveTriggerTimer.stop()
		
		# Save rails touching
		rails_touching = result["rails"]
	


	# @OPTIMIZE adding/removing from employees every frame isn't necessary
	# Do per-rail logic
	var was_delivered = delivered
	delivered = false
	for rail in rails_touching:
		# Mark rail pressed, and add to glow
		rail.glow += delta * 10
		rail.glow = min(rail.glow, 1)
		
		# Mark ourselves as delivered, if this rail is a target and we're still
		if velocity == Vector3.ZERO:
			if rail.is_target: delivered = true
			if rail.attached_to_boss: add_to_group("Employees")
	
	if always_delivered_hack:  delivered = true
		
	# Of rails that just stopped moving, check if we're touching any,
	# and if so, count that we're touching them
	for rail in controller.rails_just_halted:
		if rail.get_parent() == self:  continue
		if (rail_nearby(rail, Vector3.ZERO)):
			var touching = false
			for edge in edges:
				if not touching and point_on_rail(global_transform.origin + edge["a"], rail)["on"] and point_on_rail(global_transform.origin + edge["b"], rail)["on"]:
					touching = true
				if touching:
					if not rail in rails_touching:
						rails_touching.append(rail)
	
	if velocity == Vector3.ZERO:
		for rail in controller.rails_just_departed:
			if rail in rails_touching:
				rails_touching.erase(rail)
		
	
	# Bumping state - make the mesh do a little bump in the direction
	# we failed to move in
	if bumping:
		bump_t += delta * 3
		if bump_t > 1:
			bump_t = 1
			bumping = false
		var bump_dist = lerp(0.06, 0, controller.ease_out_quad(bump_t))
		$MeshInstance.translation = Vector3(0.5, 0.5, 0.5) + bump_dist * bump_dir / scale
		if not flesh == null:
			flesh.translation = $MeshInstance.translation

	if delivered and not was_delivered:
		emit_signal("signal_delivered", self, true)
		$DeliveredSound.play()
	elif was_delivered and not delivered:
		emit_signal("signal_delivered", self, false)
		$UndeliveredSound.play()

# A box is defined to be on the rails if it has at least 1 edge where both vertices are on any rail.
func on_rails(to_move):
	var valid = false
	var rails = {} # Use a dictionary for rails instead of an array to prevent duplicate entries
	
	# Only check nearby rails, for performance which I think will become a problem
	# once we have hundreds of rails.
	# Note: it's very possible this optimization isn't good enough or has failure cases!
	var nearby_rails = Array()
	for rail in controller.rails:
		if rail.get_parent() == self:  continue
		if rail_nearby(rail, to_move):
			nearby_rails.append(rail)
	
	for edge in edges:
		var a = false
		var b = false
		var c = false
		for rail in nearby_rails:
			
			var result = point_on_rail(get_global_transform().origin + to_move + edge["a"], rail)
			if result["on"]:
				a = true
				if not result["barely"]: rails[rail] = true

			result = point_on_rail(get_global_transform().origin + to_move + edge["b"], rail)
			if result["on"]:
				b = true
				if not result["barely"]: rails[rail] = true
			
			# Check midpoint (kind of hacky)
			result = point_on_rail(get_global_transform().origin + to_move + lerp(edge["a"], edge["b"], 0.2), rail)
			if result["on"]:
				c = true
				if not result["barely"]: rails[rail] = true
				
			result = point_on_rail(get_global_transform().origin + to_move + lerp(edge["a"], edge["b"], 0.4), rail)
			if result["on"]:
				c = true
				if not result["barely"]: rails[rail] = true
				
			result = point_on_rail(get_global_transform().origin + to_move + lerp(edge["a"], edge["b"], 0.6), rail)
			if result["on"]:
				c = true
				if not result["barely"]: rails[rail] = true
				
			result = point_on_rail(get_global_transform().origin + to_move + lerp(edge["a"], edge["b"], 0.8), rail)
			if result["on"]:
				c = true
				if not result["barely"]: rails[rail] = true
					
		# All 3 points on this edge must be on a rail for it to be a valid position
		if a and b and c:
			valid = true
	
	# Check if we're colliding with another box.
	# This is jank, but kinda works.
	var my_shape = get_node("CollisionShape")
	var my_pos = my_shape.get_global_transform().origin
	var my_extents = my_shape.shape.extents * scale
	for box in controller.boxes:
		if box == self:  continue
		if is_the_boss and box.is_in_group("Employees"): continue
		if not rail_nearby(box, to_move):  continue

		var other_shape = box.get_node("CollisionShape")
		var other_pos = other_shape.get_global_transform().origin
		var other_extents = other_shape.shape.extents * box.scale

		if rectangular_prisms_overlap(my_pos + to_move, my_extents, other_pos, other_extents):
			valid = false
			break
			
#	for ground in controller.grounds:
#		#if not rail_nearby(ground, to_move):  continue
#		var other_shape = ground.get_node("Area").get_node("CollisionShape")
#		var other_pos = other_shape.get_global_transform().origin
#		var other_extents = other_shape.shape.extents * ground.scale
#		other_pos -= other_extents/2
#
#		if rectangular_prisms_overlap(my_pos + to_move, my_extents, other_pos, other_extents):
#			valid = false
#			break
			
	return {"valid": valid, "rails": rails.keys()}

func rectangular_prisms_overlap(a_pos, a_extents, b_pos, b_extents):
	var a_min = a_pos - a_extents/2
	var a_max = a_pos + a_extents/2
	var b_min = b_pos - b_extents/2
	var b_max = b_pos + b_extents/2
	
	var miss = a_min.x >= b_max.x or a_min.y >= b_max.y or a_min.z >= b_max.z or b_min.x >= a_max.x or b_min.y >= a_max.y or b_min.z >= a_max.z
	return not miss

# Rough check if the rail is closeby on the grid
func rail_nearby(rail, to_move):
	var cutoff = 1 + max(max(scale.x, scale.y), scale.z)
	var me = get_global_transform().origin + to_move
	var them = rail.get_global_transform().origin
	if abs(round(me.x) - round(them.x)) > cutoff: return false
	if abs(round(me.y) - round(them.y)) > cutoff: return false
	if abs(round(me.z) - round(them.z)) > cutoff: return false
	return true

func point_on_rail(point, rail):
	var line_a = rail.get_global_transform().origin
	# We get the basis here to account for the rails being rotated in the scene editor
	var line_b = rail.get_global_transform().origin + rail.transform.basis.x.normalized()
	
	# This formula is from: https://stackoverflow.com/a/17590923/2134837
	var ab = (line_a - line_b).length()
	var ap = (point - line_a).length()
	var pb = (point - line_b).length()
	var difference = abs(ab - (ap + pb))
	# Note: epsilon of 0.001 here was chosen pretty arbitrarily
	var on = difference < 0.01
	var barely = (ap < 0.001) != (pb < 0.001)
	return {"on": on, "barely": barely}
	
	
func get_nearest_face(collision_position, ray, highlight_info):
	var local_pos = collision_position - get_world_center()
	var x_basis = global_transform.basis.x * mesh.scale.x
	var y_basis = global_transform.basis.y * mesh.scale.y
	var z_basis = global_transform.basis.z * mesh.scale.z
	
	var x = local_pos.dot(x_basis)
	var y = local_pos.dot(y_basis)
	var z = local_pos.dot(z_basis)
	
	x = x / (scale.x * scale.x)
	y = y / (scale.y * scale.y)
	z = z / (scale.z * scale.z)
		
	var face
	var basis = []
	if abs(x) > abs(y):
		if abs(x) > abs(z):
			if x > 0:
				face = Face.X_PLUS
				basis = [y_basis, z_basis, x_basis]
			else:
				face = Face.X_MINUS
				basis = [y_basis, z_basis, -x_basis]
		else:
			if z < 0: 
				face = Face.Z_MINUS
				basis = [x_basis, y_basis, -z_basis]
			else:
				face = Face.Z_PLUS
				basis = [x_basis, y_basis, z_basis]
	elif abs(y) > abs(z):
		if y > 0:
			face = Face.Y_PLUS
			basis = [z_basis, x_basis, y_basis]
		else:
			face = Face.Y_MINUS
			basis = [z_basis, x_basis, -y_basis]
	else:
		if z < 0: 
			face = Face.Z_MINUS
			basis = [x_basis, y_basis, -z_basis]
		else:
			face = Face.Z_PLUS
			basis = [x_basis, y_basis, z_basis]
	
	var dot_threshold = .075
	if abs(ray.dot(basis[2])) < dot_threshold:
		highlight_info.cool = false
	else: 
		highlight_info.cool = true
		highlight_info.dirs = basis
		highlight_info.face = face
	
	return highlight_info
	

	
func get_world_center ():
	var x = global_transform.basis.x * mesh.scale.x
	var y = global_transform.basis.y * mesh.scale.y
	var z = global_transform.basis.z * mesh.scale.z
	return global_transform.origin + x + y + z
	
func get_world_center_with_bumping():
	var mesh_bumped = mesh.translation - Vector3.ONE * .5
	return get_world_center() + mesh_bumped
	

func moving():
	return velocity != Vector3.ZERO
	
func reset_transform_to_initial_values():
	translation = initial_translation
	rotation = initial_rotation
		
func face_pulled(face):
	if moving(): return
	
	$moveTriggerTimer.start()
	
	match face:
		Face.X_PLUS:
			grab_velocity = Vector3.RIGHT
			continue
		Face.X_MINUS:
			grab_velocity = Vector3.LEFT
			continue
		Face.Y_PLUS:
			grab_velocity = Vector3.UP
			continue	
		Face.Y_MINUS:
			grab_velocity = Vector3.DOWN
			continue
		Face.Z_PLUS:
			grab_velocity = Vector3.BACK
			continue
		Face.Z_MINUS:
			grab_velocity = Vector3.FORWARD
			continue
	grab_velocity *= box_speed
			
	
#not used by Cubio, only the old player	
func was_pulled (collision_position):
	# don't want to interrupt a moving box!
	if velocity != Vector3.ZERO: return
	
	var pos = collision_position - translation
	
	var leeway = 0.01
	if abs(pos.x - 0) < leeway:
		grab_velocity = Vector3.LEFT
	elif abs(pos.x - scale.x) < leeway:
		grab_velocity = Vector3.RIGHT
	elif abs(pos.y - 0) < leeway:
		grab_velocity = Vector3.DOWN
	elif abs(pos.y - scale.y) < leeway:
		grab_velocity = Vector3.UP
	elif abs(pos.z - 0) < leeway:
		grab_velocity = Vector3.FORWARD
	elif abs(pos.z - scale.z) < leeway:
		grab_velocity = Vector3.BACK
	else:
		print ("BADDDDDDDDD")
	grab_velocity *= box_speed
	
	
	
func become_human(flesh_rot, promote_to_boss = false):
	if not flesh == null:
		return
		
	$MeshInstance.hide()
	flesh = load("res://player/PlayerFace.tscn").instance()
	add_child((flesh))
	flesh.translation = mesh.scale
	flesh.set_rotation(flesh_rot)
	
	if promote_to_boss:
		var boss_face = load("res://boss/andre_cube.jpg")
		for s in flesh.get_children():
			if s is Sprite3D:
				s.texture = boss_face
	
	
func become_box():
	$MeshInstance.show()
	if not flesh == null:
		flesh.hide()
		flesh.queue_free()
		flesh = null

func check_for_rail_attached_to_boss():
	var result = on_rails(Vector3())
	if result["valid"]:
		var rails_just_attached_to = result["rails"]
		for rail in rails_just_attached_to:
				if rail.is_target: delivered = true
				if rail.attached_to_boss: 
					add_to_group("Employees")
					print ("boxformed on rails, added to employees")
	else: print ("box form not on rails")


func _on_moveTriggerTimer_timeout():
	# If a box has moved for at least Timer.wait_time long
	# then it has moved and emit the "moved" signal
	# The moved signal triggers updating the move counter
	emit_signal("moved")
	
