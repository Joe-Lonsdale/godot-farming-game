class_name SellBox extends Storage

@export var storage_item: StorageData

func can_interact(player: Player) -> bool:
	if !player.held_item:
		return false
	for entry in player.held_item.get_property_list():
		if entry["name"] == "sell_price":
			return true
	return false

func interact(player: Player) -> void:
	player.money = player.money + player.held_item.get("sell_price")
	storage_item.add_to_inventory(player.held_item)
	storage_item.remove_from_inventory(player.held_item)
	player.held_item.queue_free()
	player.held_item = null

func put_down_on(body: Node3D, player: Player):
	var can_sell := false
	for i in body.get_property_list():
		if i.name == "sell_price":
			can_sell = true
	if !can_sell:
		return false
	player.money += body.get("sell_price")
	storage_item.add_to_inventory(body)
	storage_item.remove_from_inventory(body)
	return true
