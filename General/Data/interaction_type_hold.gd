class_name InteractionTypeHold extends InteractionType

@export var hold_time := 1.0
var curr_held_time := 0.0
var is_being_held := true
signal interact

func get_action_type() -> String:
	return "Hold"
	
func hold_for(delta: float):
	curr_held_time += delta
	if curr_held_time >= hold_time:
		interact.emit()
		curr_held_time = 0.0
