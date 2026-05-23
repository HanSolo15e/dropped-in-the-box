extends Node
# ok so yeahhhh i kinda slapped this togther it works better.... still bad prob

var _model_cache: Dictionary = {}

func clear_cache():
	_model_cache = {}

func get_model_data(model_path: String) -> Dictionary:
	# check if we alredy inslaved the model in ram
	if _model_cache.has(model_path):
		return _model_cache[model_path]
	
	# Otherwise, load and process it
	var scene = load(model_path).instantiate()
	var mesh_nodes = scene.find_children("*", "MeshInstance3D", true)
	
	if mesh_nodes.size() > 0:
		var target_mesh = mesh_nodes[0].mesh
		# Generate the shape ONE SINGLE TIME and store it
		var target_shape = target_mesh.create_convex_shape(true, true)
		
		var data = {
			"mesh": target_mesh,
			"shape": target_shape
		}
		
		_model_cache[model_path] = data
		scene.queue_free()
		return data
		
	scene.queue_free()
	return {}
