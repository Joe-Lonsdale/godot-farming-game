class_name ProgressBar3D extends Node3D

@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var subviewport: SubViewport = $SubViewport
@onready var fill_stylebox: StyleBoxFlat = load("uid://clgc1t021jc7h")

func _ready() -> void:
	subviewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	pass
	
func set_value(value: float):
	progress_bar.value = value

func set_color(color: Color):
	var new_stylebox: StyleBoxFlat = fill_stylebox.duplicate()
	new_stylebox.bg_color = color
	progress_bar.add_theme_stylebox_override("fill", new_stylebox)
