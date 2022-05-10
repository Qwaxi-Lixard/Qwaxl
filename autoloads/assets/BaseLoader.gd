extends Node
class_name BaseLoader
signal loading_progressed()

const items = {}

var TYPES = []
var RESOURCE_DIR = ""
var _resources_to_load = []


func start_loading() -> void:
	for i in len(_resources_to_load):
		var resource_path: String = _resources_to_load[i]
		var name: String = resource_path.split(".")[0]
		var resource = load(RESOURCE_DIR + resource_path)
		if resource is AudioStream:
			items[name] = resource
		
		Msg.broadcast("loading-progressed")


func get_resource_list() -> Array:
	if _resources_to_load.empty():
		_resources_to_load = _get_resource_list()
	
	return _resources_to_load


func _get_resource_list(subdir: String = "") -> Array:
	var dir := Directory.new()
	var res_list := []
	
	if subdir != "":
		subdir += "/"
	
	if dir.open(RESOURCE_DIR + subdir) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				res_list.append_array(
					_get_resource_list(subdir + file_name)
				)
			
			else:
				var results = file_name.split(".")
				if results[-1] in TYPES:
					res_list.append(subdir + file_name)
				
				file_name = dir.get_next()
	
	return res_list
