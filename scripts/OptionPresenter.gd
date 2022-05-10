extends Node
class_name Choice

export (NodePath) var option_path
export (String) var msg_listener_name = "option_presenter"
onready var options: VBoxContainer = get_node(option_path)

func _ready() -> void:
	Msg.listen_for(msg_listener_name,  "show-options",  funcref(self, "_show_options_message"))
	Msg.listen_for(msg_listener_name, "clear-options", funcref(self, "_clear_options_message"))


func show_options(option_list: Array) -> void:
	assert(len(option_list) % 2 == 0, "Options must be multiples of 2")
	
	var count = min(6, len(option_list))
	for i in range(0, count, 2):
		_add_option(option_list[i], option_list[i + 1])


func _show_options_message(data: Dictionary) -> void:
	show_options(data.options)


func clear_options() -> void:
	for child in options.get_children():
		options.remove_child(child)
		child.queue_free()


func _clear_options_message(_data: Dictionary) -> void:
	clear_options()


func _add_option(text: String, tag: String) -> void:
	var button = Button.new()
	button.text = text
	button.connect("pressed", self, "_on_button_pressed", [options.get_child_count(), tag])
	options.add_child(button)


func _on_button_pressed(idx: int, tag: String) -> void:
	Msg.broadcast("%s/option-picked" % msg_listener_name, { idx = idx, tag = tag })
