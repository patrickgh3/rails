extends Spatial

onready var player_head = $HEAD_PLAYER_NORMAL
onready var boss_head_looking = $HEAD_BOSS_LOOKING
onready var boss_head_normal = $HEAD_BOSS_NORMAL
onready var boss_head_smug = $HEAD_BOSS_SMUG
onready var bird_head = $HEAD_BOSS_BIRD



onready var arms = $ARM
onready var torso = $TORSO
onready var legs = $LEG
onready var shoes = $SHOES

var head
var in_first = true

func _ready():
	head = player_head
	

func swap_to_player_head():
	var was_showing = head.is_visible()
	head.hide()
	head = player_head
	if was_showing: 
		head.show()
	else: head.hide()

func swap_to_boss_head_looking():
	var was_showing = head.is_visible()
	head.hide()
	head = boss_head_looking
	if was_showing: 
		head.show()
	else: head.hide()
	
	
func swap_to_boss_head_normal():
	var was_showing = head.is_visible()
	head.hide()
	head = boss_head_normal
	if was_showing: 
		head.show()
	else: head.hide()
	
func swap_to_boss_head_smug():
	var was_showing = head.is_visible()
	head.hide()
	head = boss_head_normal
	if was_showing: 
		head.show()
	else: head.hide()
	
func swap_to_bird_head():
	var was_showing = head.is_visible()
	head.hide()
	head = bird_head
	if was_showing: 
		head.show()
	else: head.hide()
	
	

func crouch():
	if in_first:
		head.hide()
		legs.hide()
	else:
		head.show()
		
	shoes.show()
	arms.hide()
	torso.hide()
	
	head.translation = Vector3(0, 0.503, .03)
	legs.translation = Vector3(0, 0, -.2)
	shoes.translation = Vector3(0, 0, -.2)
	
func stand_up():
	if in_first:
		head.hide()
		arms.hide()
		torso.hide()
		legs.hide()
	else:
		head.show()
		#arms.show()
		torso.show()
		legs.show()
		
	shoes.show()
	
	head.translation = Vector3.ZERO
	legs.translation = Vector3.ZERO
	shoes.translation = Vector3.ZERO


func first_person():
	in_first = true
	head.hide()
	arms.hide()
	torso.hide()
	legs.hide()
	
func third_person():
	in_first = false
	head.show()
	arms.show()
	torso.show()
	legs.show()
