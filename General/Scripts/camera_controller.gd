class_name CameraController extends Camera3D

@onready var garden_boundary: GridMap = $"../GridMap"

var players: Array[Player] = []
var player_positions: Array[Vector3] = []
var zoom: float = 1.0
var center_pos: Vector3 = Vector3.ZERO
var default_position: Vector3
var garden_boundary_aabb: AABB

func _ready() -> void:
	var world: Node3D = get_parent()
	default_position = global_position
	for node in world.get_children():
		if node is Player:
			players.append(node)
	var meshes = garden_boundary.get_meshes()
	var corner_1: Vector3 = Vector3.ZERO
	var corner_2: Vector3 = Vector3.ZERO
	var x_and_z_coords = []
	garden_boundary_aabb = AABB(Vector3.ZERO, Vector3.ZERO)
	for mesh_index in range(meshes.size()):
		if mesh_index % 2 == 0:
			var t: Transform3D = meshes[mesh_index]
			garden_boundary_aabb = garden_boundary_aabb.expand(Vector3(t.origin.x, t.origin.y, t.origin.z))
	garden_boundary_aabb = garden_boundary_aabb.expand(Vector3(0.0,-1.0,0.0))
	garden_boundary_aabb = garden_boundary_aabb.expand(Vector3(0.0,1.0,0.0))
	print(garden_boundary_aabb)

func _physics_process(delta: float) -> void:
	var new_zoom = 1.0
	var new_center_pos: Vector3
	player_positions = []
	for player: Player in players:
		player_positions.append(player.global_position)
	if player_positions.all(func(x: Vector3): return !garden_boundary_aabb.has_point(x)):
		var max_dist_from_origin := 0.0
		for pos in player_positions:
			new_center_pos += pos / player_positions.size()
			if abs(pos.x) > max_dist_from_origin:
				max_dist_from_origin = abs(pos.x)
			if abs(pos.z) > max_dist_from_origin:
				max_dist_from_origin = abs(pos.z)
		new_zoom = 1.0 + max_dist_from_origin * 0.5
	zoom = lerp(zoom, new_zoom, delta)
	center_pos = lerp(center_pos, new_center_pos, delta)
	move_camera_for_zoom_level(center_pos)
	pass

func move_camera_for_zoom_level(center_pos: Vector3):
	var vector_to_move_along: Vector3 = center_pos.direction_to(default_position)
	global_position = center_pos + default_position + vector_to_move_along * zoom
