extends Spatial

onready var player_head = $Mesh/HEAD_PLAYER_NORMAL
onready var boss_head_looking = $Mesh/HEAD_BOSS_LOOKING
onready var boss_head_normal = $Mesh/HEAD_BOSS_NORMAL
onready var boss_head_smug = $Mesh/HEAD_BOSS_SMUG
onready var bird_head = $Mesh/HEAD_BOSS_BIRD


var head

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
