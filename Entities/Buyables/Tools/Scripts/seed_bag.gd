class_name SeedBag extends Tool

@export var crop: CropData
@onready var seed_bag_colour_material: StandardMaterial3D = preload("uid://b3u5d2cvwepjw")

func _ready() -> void:
	if crop:
		set_seed_bag_color()

func set_seed_bag_color():
	var my_seed_bag_colour_material = seed_bag_colour_material.duplicate()
	for c in get_children():
		if c is MeshInstance3D:
			if c.get_surface_override_material_count() == 3:
				my_seed_bag_colour_material.albedo_color = crop.seed_bag_color
				c.set_surface_override_material(0, my_seed_bag_colour_material)

func pick_up(player: Player):
	return

func on_put_down(body_put_down_on: Node3D):
	if body_put_down_on is SeedBagCrate:
		queue_free()
	
