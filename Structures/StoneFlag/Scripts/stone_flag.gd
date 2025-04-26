class_name StoneFlag extends StaticBody3D

@onready var storage: ToolStorageItem = load("uid://diugoskccihh8").duplicate()
@onready var mesh: MeshInstance3D = $Cube_013

func put_down_on(body: Node3D, player: Player):
	if storage.get_inventory().size() == 0:
		storage.add_to_inventory(body)
		
		return true
	return false

func get_item_to_pick_up(player: Player):
	if storage.get_inventory().size() == 1:
		var item_to_pick_up: Node3D = storage.get_inventory()[0]
		storage.remove_from_inventory(storage.get_inventory()[0])
		return item_to_pick_up

func get_aabb() -> AABB:
	return mesh.get_aabb()
