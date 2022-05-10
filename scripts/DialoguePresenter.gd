extends Node
class_name Chatter

const DIALOGUE_COMPLETED: String = "dialogue-completed"
const FRAME: float = 1.0/60.0
const DialogueLine := preload("res://addons/dialogue_manager/dialogue_line.gd")

export (NodePath) var dialogue_path
export (String) var msg_listener_name = "dialogue_presenter"

onready var rtl: RichTextLabel = get_node(dialogue_path)
onready var tween: Tween = Tween.new()

var _mutations: Dictionary = {}
var _line: DialogueLine = null


func _ready() -> void:
	Msg.listen_for(msg_listener_name,  "show-dialogue",  funcref(self, "_show_dialogue_message"))
	Msg.listen_for(msg_listener_name, "clear-dialogue", funcref(self, "_clear_dialogue_message"))
	tween.connect("tween_step", self, "_on_tween_step") # warning-ignore:return_value_discarded
	add_child(tween)


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		tween.seek(tween.get_runtime()) # warning-ignore:return_value_discarded
		for i in _mutations:
			_line.mutate_inline_mutations(i)
			# _mutations.erase(i) # warning-ignore:return_value_discarded


func _on_tween_step(_object: Object, _key: NodePath, _elapsed: float, value) -> void:
	value = int(value)
	if value in _mutations:
		_line.mutate_inline_mutations(value)
		_mutations.erase(value) # warning-ignore:return_value_discarded


func clear_dialogue() -> void:
	rtl.clear()


func show_dialogue(message: String, line: DialogueLine) -> void:
	_mutations = {}
	_line = line
	rtl.text = ""
	rtl.bbcode_text = ""
	rtl.clear()
	rtl.append_bbcode(message) # warning-ignore:return_value_discarded
	rtl.visible_characters = 0
	
	tween.remove_all() # warning-ignore:return_value_discarded

	for mutation in line.inline_mutations:
		_mutations[mutation[0]] = true

	var pauses: Dictionary = line.pauses
	print(pauses)
	if pauses.empty():
		_show_text(0, len(rtl.text), FRAME * 2)

	else:
		var chars: int = 0
		var delay: float = 0.0
		var indexes: Array = pauses.keys()
		indexes.sort()
		for index in indexes:
			_show_text(chars, index, FRAME * 2, delay)
			
			print(message[index])
			if index != len(message):
				chars = index
				delay += pauses[index]
		
		if chars != len(message):
			_show_text(chars, len(message), FRAME * 2, delay)
	
	tween.start() # warning-ignore:return_value_discarded
	yield(tween, "tween_all_completed")


func _show_text(from: int, to: int, delay_between_chars: float, wait: float = 0) -> void:
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		rtl, 
		"visible_characters", 
		from, to, (to - from) * delay_between_chars, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, wait) 


func _show_dialogue_message(data: Dictionary) -> void:
	yield(show_dialogue(data.message, data.line), "completed")
	Msg.broadcast("%s/dialogue-completed" % msg_listener_name)


func _clear_dialogue_message(_data: Dictionary) -> void:
	clear_dialogue()
