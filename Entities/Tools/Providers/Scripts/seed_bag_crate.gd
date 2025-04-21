class_name SeedBagCrate extends Node3D

@export var crop: CropItem
@onready var seed_bag_colour_material: StandardMaterial3D = load("res://Entities/Tools/Materials/seed_bag.tres")
@onready var seed_bag_crate_data: ToolProviderItem = load("res://Entities/Tools/Providers/Data/seed_bag_crate.tres")

func _ready() -> void:
	var my_seed_bag_colour_material = seed_bag_colour_material.duplicate()
	for c in get_children():
		if c is MeshInstance3D:
			if c.get_surface_override_material_count() == 4:
				my_seed_bag_colour_material.albedo_color = crop.seed_bag_color
				c.set_surface_override_material(0, my_seed_bag_colour_material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

			
	pass

func get_interaction_type():
	return seed_bag_crate_data.InteractionType

func interact(player: Player):
	var player_pick_up_response = player.pick_up(crop.seed_bag_model)
	if player_pick_up_response[1]:
		var seed_bag_node: SeedBag = player_pick_up_response[0]
		if seed_bag_node:
			seed_bag_node.set("crop", crop)
			seed_bag_node.set_seed_bag_color()
	else:
		if player_pick_up_response[0].get("crop") == crop:
			player.put_down()
		
