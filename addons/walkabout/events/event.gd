@icon("event.svg")
class_name WBEvent
extends Node
## Basic event that does nothing and emits its signals.


## Emitted when the event starts performing.
signal event_started()
## Emitted when the event has finished performing.
signal event_finished()


## [constant true] when the event is currently active.
## It is an error to try to perform an event that is already running.
var running: bool = false


## Starts the event.
func perform() -> void:
	if running:
		push_error("Event may not be performed if it is already running.")
	
	running = true
	event_started.emit()
	
	await _perform()
	
	running = false
	event_finished.emit()


func _perform() -> void:
	pass
