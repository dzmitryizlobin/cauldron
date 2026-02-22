@icon("walk_character_event.svg")
class_name WBWalkCharacterEvent
extends WBEvent
## Event that makes a character walk a certain distance in the given direction.


## Character to move.
@export var character: WBCharacter
## Direction for the character to walk.
@export var direction: WBCharacter.Dir
## Number of tiles to move the character.
@export_custom(0, "suffix:tiles") var distance: int
## Whether the character should be running.
@export var run: bool = false


func _perform() -> void:
	if not character:
		push_error("Target character does not exist.")
		return
	
	character.running = run
	var remaining_distance := distance
	while remaining_distance > 0:
		character.start_move(direction, true)
		await character.move_finished
		remaining_distance -= 1
