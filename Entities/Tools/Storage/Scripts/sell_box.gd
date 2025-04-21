class_name SellBox extends StaticBody3D

@export var storage_item: ToolStorageItem

func can_interact(player: Player) -> bool:
	if !player.heldItem:
		return false
	for entry in player.heldItem.get_property_list():
		if entry["name"] == "sell_price":
			return true
	return false

func interact(player: Player) -> void:
	player.money = player.money + player.heldItem.get("sell_price")
	storage_item.add_to_inventory(player.heldItem)
	storage_item.remove_from_inventory(player.heldItem)
	player.heldItem.queue_free()
	player.heldItem = null
