@tool
extends EditorScenePostImport

# This script assumes that the .glb file being imported has been exported from Blender with the -col suffix.
# It also assumes that the root type of the imported model has been set to StaticBody3D.

# The tree structure pre-import is:
# Node3D
# -- MeshInstance3D
# -- -- StaticBody3D
# -- -- -- CollisionShape3D

# The tree structure post-import is:
# StaticBody3D
# -- MeshInstance3D
# -- CollisionShape3D

# This structure allows a script to be attached to the StaticBody3D,
# and collisions can directly interact with the script.

func _post_import(scene):
	var root = scene
	var mesh = scene.get_children()[0]
	var body = mesh.get_children()[0]
	var collision = body.get_children()[0]
	collision.owner = null
	body.remove_child(collision)
	scene.add_child(collision)
	collision.owner = scene
	body.queue_free()
	print("Successfully Imported...")
	return scene
