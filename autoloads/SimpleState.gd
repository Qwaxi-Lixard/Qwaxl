extends Node

signal state_changed(name, state)

var state := { }

onready var msg: Msg = get_node_or_null("/root/msg")

func _ready():
	if msg:
		msg.listen_for("global/state", "update-state", funcref(self, "_on_update_state"))


func register(name: String, inital_state: Dictionary = {}) -> void:
	state[name] = inital_state


func update(name: String, new_state: Dictionary) -> void:
	state[name] = merge(get_state(name), new_state)

	if msg:
		msg.broadcast('global/state/%s' % name, { state = state[name] })
	
	emit_signal("state_changed", name, state)


func update_mut(name: String, new_state: Dictionary) -> void:
	copy_to(state[name], new_state)

	if msg:
		msg.broadcast('global/state/%s' % name, { state = state[name] })

	emit_signal("state_changed")


func _on_update_state(data: Dictionary) -> void:
	update(data.name, data.state)


static func copy_to(a: Dictionary, b: Dictionary) -> void:
	for key in b:
		a[key] = b[key]


static func merge(a: Dictionary, b: Dictionary) -> Dictionary:
	var c := {}
	copy_to(c, a)
	copy_to(c, b)
	return c


func get_state(name: String) -> Dictionary:
	return state[name].duplicate()
