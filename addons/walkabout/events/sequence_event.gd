@icon("sequence_event.svg")
class_name WBSequenceEvent
extends WBEvent
## Event that performs each child event in sequence, one after another.


func _perform() -> void:
	event_started.emit()
	for child in get_children():
		if child is WBEvent:
			await child.perform()
	event_finished.emit()
