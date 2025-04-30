class_name WateringCan extends Tool

@onready var collision := $CollisionShape3D

var fill_level := 100


func pick_up(player: Player):
	pass
	
func on_pick_up(player: Player, pick_up_response: Variant):
	var held_item = pick_up_response[0]
	var pick_up_successful: bool = pick_up_response[1]
	if held_item == self:
		collision.disabled = true
		
func on_put_down(body_put_down_on: Node3D):
	collision.disabled = false
