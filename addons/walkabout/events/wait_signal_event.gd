@icon("wait_signal_event.svg")
class_name WBWaitSignalEvent
extends WBEvent
## Event that waits for a specified signal on a target node to be emitted.


## Node to await a signal of.
@export var target: Node
## Signal to await.
@export var signal_to_await: StringName = &""


func _perform() -> void:
	if not target:
		push_error("Target object is not specified.")
		return
	if not target.has_signal(signal_to_await):
		push_error("Target does not have the specified signal.")
		return
	
	await Signal(target, signal_to_await)
