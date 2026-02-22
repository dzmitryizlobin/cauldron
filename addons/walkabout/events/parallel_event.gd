@icon("parallel_event.svg")
class_name WBParallelEvent
extends WBEvent
## Event that starts all child events at the same time, then finishes once all have completed.


signal _children_finished()


var _children_running: int = 0


func _perform() -> void:
	for child in get_children():
		if child is WBEvent:
			_start_child(child)
	if _children_running > 0:
		await _children_finished


func _start_child(event: WBEvent) -> void:
	_children_running += 1
	await event.perform()
	_children_running -= 1
	if _children_running <= 0:
		_children_finished.emit()
