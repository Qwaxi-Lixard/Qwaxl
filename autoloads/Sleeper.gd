extends Node

class CoroutineLock:
	extends Reference
	signal unlocked(data)

	func unlock(data = null):
		emit_signal("unlocked", data)


const _wait_locks = {}
const _action_locks = {}


func wait(name: String) -> void:
	if not name in _wait_locks:
		_wait_locks[name] = CoroutineLock.new()
		
	return yield(_wait_locks[name], "unlocked")


func wait_action(action: String) -> void:
	assert(InputMap.has_action(action), "Action %s does not exist in InputMap. Lock will never release." % action)

	if not action in _action_locks:
		_action_locks[action] = CoroutineLock.new()
	
	yield(_action_locks[action], "unlocked")


func wait_time(time: float) -> void:
	yield(get_tree().create_timer(time), "timeout")


func notify(who: String, data = null) -> void:
	_notify(who, _wait_locks, data)


func _input(event: InputEvent) -> void:
	for action in _action_locks:
		if event.is_action_released(action) and not event.is_echo():
			_notify(action, _action_locks)


func _notify(who: String, locks = _wait_locks, data = null) -> void:
	if who in locks:
		locks[who].unlock(data)
		locks.erase(who)
