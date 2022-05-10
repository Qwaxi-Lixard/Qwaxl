extends Node

var _routing = {}

func listen_for(listener: String, message: String, callback: FuncRef, once = false) -> void:
	if message in _routing:
		_routing[message][listener] = { callback = callback, once = once }
	else:
		_routing[message] = {listener: { callback = callback, once = once }}


func await_for(listener: String, message: String):
	listen_for(listener, message, null, true)
	return yield(Sleeper.wait("%s/%s" % [listener, message]), "completed")


func cast(listener: String, message: String, data: Dictionary = {}) -> void:
	prints(listener, message)
	if message in _routing:
		var router: Dictionary = _routing[message]
		
		if listener in router:
			_try_call(router, message, listener, data)


func broadcast(message: String, data: Dictionary = {}) -> void:
	
	if message in _routing:
		var router: Dictionary = _routing[message] 
		
		for listener in router.keys():
			_try_call(router, message, listener, data)


func randomcast(message: String, data: Dictionary = {}) -> void:
	if message in _routing:
		var routes := _routing[message] as Dictionary
		var route_list := routes.keys()
		var listener := route_list[randi() % len(route_list)] as String
		
		_try_call(routes, message, listener, data)


func _try_call(router: Dictionary, message: String, listener: String, data: Dictionary):
	var actor: Dictionary = router[listener]
	var callback: FuncRef = actor.callback
	var once: bool = actor.once
	data.msg = { message = message, listener = listener }

	if callback and callback.is_valid():
		callback.call_func(data)
		if once:
			router.erase(listener) # warning-ignore:return_value_discarded

	else:
		router.erase(listener) # warning-ignore:return_value_discarded
	
	Sleeper.notify("%s/%s" % [listener, message], data)
