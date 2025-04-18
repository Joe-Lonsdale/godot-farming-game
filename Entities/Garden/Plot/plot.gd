class_name Plot extends Node3D

@export var crop: CropItem ## CropItem to be planted in this Plot.
@export_range(1,8) var number_of_crops_power_2 := 4 ## Sets N where N^2 will be the number of crops planted. 
@export var margin := 0.2 ## Margin (in metres) between the edge of the plot, and where crops can be placed

var crops: Array[Node3D] = []
var tween: Tween
var isGrowing: bool = false

func _ready() -> void:
	plant_crop(crop)
	pass
	
func _physics_process(delta: float) -> void:
	pass
	
func plant_crop(crop: CropItem) -> void:
	isGrowing = true
	var offset: float = (2.0 - margin * 2) / (number_of_crops_power_2)
	crops = []
	var valid_positions = []
	for y in range(number_of_crops_power_2):
		for x in range(number_of_crops_power_2):
			valid_positions.append([x,y])
	tween = get_tree().create_tween()
	tween.set_parallel()
	for pos in valid_positions:
		var new_crop: Node3D = crop.scene.instantiate()
		add_child(new_crop)
		new_crop.scale = Vector3(0.1,0.1,0.1)
		new_crop.position = Vector3(offset*(pos[0] - ((number_of_crops_power_2)/2)+0.5) + randf_range(-offset/4, offset/4),randf_range(0.3, 0.45),offset*(pos[1] - ((number_of_crops_power_2)/2)+0.5)  + randf_range(-offset/4, offset/4)) 
		crops.append(new_crop)
		tween.tween_property(new_crop, "scale", Vector3(1,1,1), crop.growth_time)
	tween.finished.connect(func (): isGrowing = false)
	pass
