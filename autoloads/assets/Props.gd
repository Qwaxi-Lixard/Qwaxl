extends BaseLoader


func _ready():
	TYPES = ResourceLoader.get_recognized_extensions_for_type("PackedScene")
	RESOURCE_DIR = "res://assets/props/"
