@tool
extends EditorScenePostImport

func _post_import(scene):
	var body: StaticBody3D = scene
	var mesh: MeshInstance3D = scene.get_children()[0]
	mesh.owner = null
	body.remove_child(mesh)
	mesh.add_child(body)
	body.owner = mesh
	print("Successfully Imported...")
	return mesh
