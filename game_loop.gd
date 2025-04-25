extends Node

@export var day_length: float = 60.0
@onready var world_node: Node3D = $"."
@onready var world_lighting_pivot: Node3D = $LightingPivot
@onready var world_lighting: DirectionalLight3D = $LightingPivot/DirectionalLight3D
@onready var lighting_position_tween: Tween
@onready var lighting_color_tween: Tween

enum GAME_STATE {
	SETUP,
	PREPARATION,
	PLAY
}

var curr_day = 0
var curr_day_time: float = 0.0
var game_state: GAME_STATE = GAME_STATE.PLAY

func _ready() -> void:
	lighting_color_tween = create_tween()
	lighting_position_tween = create_tween()
	world_lighting_pivot.rotation_degrees = Vector3(0.0, 0.0, -60.0)
	lighting_position_tween.tween_property(world_lighting_pivot, "rotation_degrees", Vector3(-10.0, 10.0, 60.2), day_length)
	lighting_color_tween.tween_property(world_lighting, "light_color", Color(1,0.95,0.94), day_length/2)
	lighting_color_tween.tween_callback(make_new_color_tween)
	pass

func make_new_color_tween():
	lighting_color_tween = create_tween()
	lighting_color_tween.tween_property(world_lighting, "light_color", Color(1,0.5,0.3), day_length/2)
	
func _physics_process(delta: float) -> void:
	if game_state == GAME_STATE.PLAY:
		curr_day_time += delta
	if curr_day_time >= day_length:
		game_state = GAME_STATE.PREPARATION
	pass
