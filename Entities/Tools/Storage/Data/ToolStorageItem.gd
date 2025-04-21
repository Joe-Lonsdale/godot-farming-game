class_name ToolStorageItem extends ToolItem

@export var storage_size: int
var _inventory: Array[Node3D]

func get_inventory() -> Array[Node3D]:
	return _inventory

func add_to_inventory(item: Node3D) -> bool:
	if _inventory.size() < storage_size:
		_inventory.append(item)
		return true
	else: 
		return false
		
func remove_from_inventory(item: Node3D) -> bool:
	if is_in_inventory(item):
		_inventory.erase(item)
		return true
	else:
		return false

func is_in_inventory(item: Node3D) -> bool:
	return item in _inventory
