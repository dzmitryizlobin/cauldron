@icon("delay_event.svg")
class_name WBDelayEvent
extends WBEvent
## Event that waits for a given duration.


## Time to wait for.
@export_custom(0, "suffix:s") var delay: float


func _perform() -> void:
	await create_tween().tween_interval(delay).finished
