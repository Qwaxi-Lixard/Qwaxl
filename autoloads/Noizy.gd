extends Node

var current_fx_layer = 0

onready var TweenNode = $Tween
onready var Main = $Main
onready var Cross = $Cross
onready var FX1 = $FX1
onready var FX2 = $FX2
onready var FX3 = $FX3
onready var FX4 = $FX4
onready var FX5 = $FX5
onready var FX6 = $FX6
onready var FX7 = $FX7
onready var FX8 = $FX8
onready var msg = get_node_or_null("/root/Msg")
onready var SfxLayers = [FX1, FX2, FX3, FX4, FX5, FX6, FX7, FX8]


func _ready():
	if msg:
		var cb := funcref(self, "_on_message")
		msg.listen_for("global/noizy",      "play-fx", cb)
		msg.listen_for("global/noizy",  "stop-all-fx", cb)
		msg.listen_for("global/noizy", "change-music", cb)
		msg.listen_for("global/noizy",   "stop-music", cb)
		msg.listen_for("global/noizy",  "start-music", cb)


func _on_message(data) -> void:
	match data.msg.message:
		"play-fx":
			play_fx(data.fx)
		
		"stop-all-fx":
			stop_all_fx()
		
		"play-music":
			play_music(data.source)

		"change-music":
			change_music(data.source)
		
		"stop-music":
			stop_music()


func play_fx(source: AudioStream) -> void:
	SfxLayers[current_fx_layer].stream = source
	SfxLayers[current_fx_layer].play()


func stop_all_fx() -> void:
	for sfx in SfxLayers:
		sfx.stop()


func play_music(source: AudioStream) -> void:
	Main.stream = source


func change_music(source: AudioStream) -> void:
	Cross.stream = source
	Cross.play()
	TweenNode.interpolate_method(self, "_change_volume_main", 1, 0, 1)
	TweenNode.interpolate_method(self, "_change_volume_cross", 0, 1, 1)
	TweenNode.interpolate_callback(self, 1.0, "_swap")
	TweenNode.start()


func stop_music() -> void:
	Main.stop()
	Cross.stop()
	TweenNode.remove_all()


func _change_volume_main(value: float) -> void:
	Main.volume_db = linear2db(value)


func _change_volume_cross(value: float) -> void:
	Cross.volume_db = linear2db(value)


func _swap() -> void:
	Main.stop()
	
	var temp = Main
	Main = Cross
	Cross = temp
