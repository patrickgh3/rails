extends Area

export(bool) var is_ending_trigger = false

const hello_receiver_string = "_on_Area_body_entered_BossHelloTrigger"
const ending_receiver_string = "_on_Area_body_entered_EndingTrigger"
const roof_receiver_string = "_on_Boss_open_roof"

func _ready():
	
	
	
	var boss
	for b in get_tree().get_nodes_in_group("Boss"):
		boss = b
	
	if boss:
		var receiver = hello_receiver_string
		var receivers_expected = 2
		if is_ending_trigger: 
			receiver = ending_receiver_string
			receivers_expected = 1
		
		
		if get_signal_connection_list("body_entered").size() != receivers_expected:
			print ("bossarea  on ", get_parent().get_parent().name, " doesn't have ", receivers_expected, " signals connected, connecting thru code.")
			var _c = connect("body_entered", boss, receiver)
			
	else: printerr("hello area couldn't find boss")

