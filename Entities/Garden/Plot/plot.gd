class_name Plot extends StaticBody3D

@export_range(1,8) var number_of_crops_power_2 := 4 ## Sets N where N^2 will be the number of crops planted. 
@export var margin := 0.2 ## Margin (in metres) between the edge of the plot, and where crops can be placed

@onready var planting_interaction_type: InteractionTypeHold = load("res://Entities/Garden/Plot/plot_interaction_planting.tres").duplicate()
@onready var harvesting_interaction_type: InteractionTypePress = load("res://Entities/Garden/Plot/plot_interaction_harvesting.tres")
@onready var interaction_type: InteractionType
@onready var progress_bar: ProgressBar3D = $ProgressBar3D

var crops: Array[Node3D] = []
var tween: Tween
var status: STATUS = STATUS.EMPTY
var growing_crop: CropItem = null
var growth_percentage: float = 0.0

enum STATUS {
	EMPTY,
	GROWING,
	GROWN
}

func _ready() -> void:
	interaction_type = planting_interaction_type
	pass
	
func _physics_process(delta: float) -> void:
	if interaction_type is InteractionTypeHold:
		if interaction_type.curr_held_time < 0.0:
			interaction_type.curr_held_time = 0.0
		if interaction_type.curr_held_time / interaction_type.hold_time > 1.0: 
			progress_bar.set_value(1.0)
		elif interaction_type.curr_held_time != 0.0:
			progress_bar.set_value(interaction_type.curr_held_time / interaction_type.hold_time)
		if !interaction_type.is_being_held:
			interaction_type.hold_for(-delta)
	
	if status == STATUS.GROWING:
		progress_bar.set_value(growth_percentage / 1.0)
	pass

func get_interaction_type():
	return interaction_type

func interact(player: Player): 
	if status == STATUS.EMPTY and player.heldItem is SeedBag:
		plant_crop(player.heldItem.get("crop"))
		player.put_down()
		progress_bar.set_value(0.0)
		interaction_type = harvesting_interaction_type
	elif status == STATUS.GROWN:
		harvest_crops(player)
		interaction_type = planting_interaction_type

func can_interact(player: Player) -> bool:
	if status == STATUS.EMPTY and player.heldItem is SeedBag:
		interaction_type.hold_time = player.heldItem.get("crop").plant_time
		return true
	elif status == STATUS.GROWN and !player.heldItem:
		return true
	return false

func plant_crop(crop: CropItem) -> void:
	status = STATUS.GROWING
	growing_crop = crop
	# Generate planting grid to place the crops
	var offset: float = (2.0 - margin * 2) / (number_of_crops_power_2)
	var valid_positions = []
	for y in range(number_of_crops_power_2):
		for x in range(number_of_crops_power_2):
			valid_positions.append([x,y])
	valid_positions.shuffle()
	# Set up tween for growing animation
	tween = get_tree().create_tween()
	tween.set_parallel()
	# Get size of crop to be grown
	var temp_node: Node3D = crop.scene.instantiate()
	var temp_mesh: MeshInstance3D = temp_node.get_children()[0]
	var mesh_size: Vector3 = temp_mesh.get_aabb().size
	
	# Choose random number of crops to show being planted
	for pos in valid_positions.slice(0,valid_positions.size() - randi_range(0, floor(valid_positions.size() / 10.0))):
		var new_crop: Node3D = crop.scene.instantiate()
		add_child(new_crop)
		new_crop.scale = Vector3(0,0,0)
		# Slightly randomise position of crops in plot
		new_crop.position = Vector3(offset*(pos[0] - ((number_of_crops_power_2)/2)+0.5) + randf_range(-offset/4, offset/4),randf_range(0.5 - 0.75 * mesh_size.y, 0.5),offset*(pos[1] - ((number_of_crops_power_2)/2)+0.5)  + randf_range(-offset/4, offset/4)) 
		new_crop.rotation_degrees = Vector3(randf_range(-5,5), randf_range(-180, 180), randf_range(-5,5))
		crops.append(new_crop)
		# Add crop to the tween for it's scale to be animated
		tween.tween_property(new_crop, "scale", Vector3(1,1,1), crop.growth_time)
		tween.tween_property(self, "growth_percentage", 1.0, crop.growth_time)
	# Set callback of tween so we know when the crops are finishing growing
	tween.finished.connect(on_fully_grown)
	progress_bar.set_color(Color(0,255,0))
	pass

func on_fully_grown():
	status = STATUS.GROWN
	progress_bar.set_value(0.0)

func harvest_crops(player: Player):
	var pickup_response = player.pick_up(growing_crop.scene)
	if pickup_response[1]:
		pickup_response[0].set("sell_price", growing_crop
	.sell_price)
	growing_crop = null
	status = STATUS.EMPTY
	for c in crops:
		c.queue_free()
	crops = []
	progress_bar.set_color(Color(255,255,255))
	growth_percentage = 0.0
