extends Node
class_name Playback

const DialogueLine := preload("res://addons/dialogue_manager/dialogue_line.gd")

const DIALOG_ROUTE = "chatter"
const CHOICE_ROUTE = "option_presenter"

export (String) var msg_dialogue = "dialogue_presenter"
export (String) var msg_options = "dialogue_presenter"
export (String) var msg_listener_name = "playback"

var dialogue: DialogueLine
var dialogue_completed = "%s/dialogue-completed" % msg_dialogue
var option_picked = "%s/option-picked" % msg_options

func run(script, entry: String = "intro") -> void:
	dialogue = yield(DialogueManager.get_next_dialogue_line(entry, script), "completed")
	while dialogue:
		var next_id = dialogue.next_id
		Msg.cast(msg_dialogue, "show-dialogue", { message = dialogue.dialogue, line = dialogue })
		yield(Msg.await_for(msg_listener_name, dialogue_completed), "completed")
		
		
		if len(dialogue.responses) > 0:
			var options = []
			for response in dialogue.responses:
				options.append(response.prompt)
				options.append(response.next_id)
				
			Msg.cast(msg_options, "show-options", { options = options })
			next_id = yield(Msg.await_for(msg_listener_name, option_picked), "completed").tag
			Msg.cast(msg_options, "clear-options")
			
		else:
			yield(Sleeper.wait_action("ui_accept"), "completed")
		
		dialogue = yield(DialogueManager.get_next_dialogue_line(next_id, script), "completed")
