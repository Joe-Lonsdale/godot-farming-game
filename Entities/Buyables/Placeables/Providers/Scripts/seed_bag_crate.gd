class_name SeedBagCrate extends Provider

@export var crop: CropData
@onready var seed_bag_colour_material: StandardMaterial3D = load("uid://b3u5d2cvwepjw")
@onready var seed_bag_crate_data: Resource = load("uid://cmy0w2vgx0432")

func _ready() -> void:
	var my_seed_bag_colour_material = seed_bag_colour_material.duplicate()
	for c in get_children():
		if c is MeshInstance3D:
			if c.get_surface_override_material_count() == 4:
				my_seed_bag_colour_material.albedo_color = crop.seed_bag_color
				c.set_surface_override_material(0, my_seed_bag_colour_material)

func _physics_process(delta: float) -> void:
	pass

func on_pick_up(player: Player, pick_up_response: Variant):
	if pick_up_response[1]:
		var seed_bag_node: SeedBag = pick_up_response[0]
		if seed_bag_node:
			seed_bag_node.set("crop", crop)
			seed_bag_node.set_seed_bag_color()

func get_item_to_pick_up(player: Player):
	return crop.seed_bag_model

func put_down_on(body: Node3D, player: Player) -> bool:
	if body is SeedBag:
		var bag_to_put_down: SeedBag = body
		if bag_to_put_down.crop == crop:
			return true
	return false
