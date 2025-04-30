@tool
extends EditorScenePostImport

var scale := Vector3(1.0, 1.0, 1.0)
var generate_collisions := true
var save_scene_automatically := true

# This assumes you import a model with a root node of StaticBody3D, and it has a child which is a MeshInstance3D.
# It will generate collisions and set scale according to the variables set above.

func _post_import(scene):
	var root: Node3D = scene as Node3D
	var body: StaticBody3D = scene
	var mesh_instance: MeshInstance3D = scene.get_children()[0]
	mesh_instance.owner = null
	body.remove_child(mesh_instance)
	mesh_instance.add_child(body)
	body.owner = mesh_instance
	if generate_collisions:
		# Create a CollisionShape3D node
		var collision_shape = CollisionShape3D.new()

		# Create a ConcavePolygonShape3D and assign the mesh's surface data
		var concave_shape = ConcavePolygonShape3D.new()

		# Extract the mesh arrays from the mesh's first surface
		var arrays = mesh_instance.mesh.surface_get_arrays(0)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var indices = arrays[Mesh.ARRAY_INDEX]

		# Check if the index array exists; if not, build it from vertices
		if indices.is_empty():
			# If the mesh doesn't use indexed arrays, generate implicit triangle indices
			if vertices.size() % 3 != 0:
				push_error("Vertex count is not divisible by 3; cannot create triangle mesh.")
				return mesh_instance
			indices = PackedInt32Array()
			for i in range(vertices.size()):
				indices.append(i)

		# Assign triangle indices and vertex positions to the concave shape
		var face_data = PackedVector3Array()
		for i in range(0, indices.size(), 3):
			face_data.append(vertices[indices[i]])
			face_data.append(vertices[indices[i + 1]])
			face_data.append(vertices[indices[i + 2]])

		concave_shape.data = face_data

		# Assign the shape to the collision shape node
		collision_shape.shape = concave_shape

		# Add the collision shape as a child of the StaticBody3D
		body.add_child(collision_shape)
		collision_shape.owner = body.owner  # Set owner for saving
		print("Successfully imported with trimesh collision.")	
	
	mesh_instance.scale = scale
	print("Successfully imported model.")
	
	if save_scene_automatically:
		# Create the new inherited scene
		var packed_scene := PackedScene.new()
		var result = packed_scene.pack(mesh_instance)
		if result != OK:
			push_error("Failed to pack imported scene.")
			return root

		var save_path := "res://imported_models/" + root.name + ".tscn"
		DirAccess.make_dir_recursive_absolute("res://imported_models")
		call_deferred("_save_inherited_scene", packed_scene, save_path)
	return mesh_instance

func _save_inherited_scene(packed_scene: PackedScene, path: String) -> void:
	var result = ResourceSaver.save(packed_scene, path)
	if result != OK:
		push_error("Deferred save failed: " + str(result))
	else:
		print("Deferred save succeeded:", path)
