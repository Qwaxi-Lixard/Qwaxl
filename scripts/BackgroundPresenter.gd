extends Node

export (NodePath) var backdrop_viewport
export (String) var msg_listener_name = "background_presenter"

onready var backdrop: Viewport = get_node(backdrop_viewport)

func _ready():
	Msg.listen_for(msg_listener_name,    "set-bg",    funcref(self, "_set_bg_message"))
	Msg.listen_for(msg_listener_name, "add-layer", funcref(self, "_add_layer_message"))
	Msg.listen_for(msg_listener_name,  "clear-bg",  funcref(self, "_clear_bg_message"))


func set_bg(bg: Array) -> void:
	clear_bg()
	for child in bg:
		backdrop.add_child(Props[name].instance())


func _set_bg_message(data: Dictionary) -> void:
	set_bg(data.bg)


func add_layer(bg: String) -> void:
	backdrop.add_child(Props[name].instance())


func _add_layer_message(data: Dictionary) -> void:
	add_layer(data.bg)


func clear_bg() -> void:
	for child in backdrop.get_children():
		backdrop.remove_child(child)
		child.queue_free()


func _clear_bg_message(_data: Dictionary) -> void:
	clear_bg()
