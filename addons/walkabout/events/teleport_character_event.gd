@icon("teleport_character_event.svg")
class_name WBTeleportCharacterEvent
extends WBEvent
## Event that teleports a character to the specified tile position.


## Character to teleport.
@export var character: WBCharacter
## Tile position to teleport the character to.
@export var target_tile: Vector2i


func _perform() -> void:
	if not character:
		push_error("Target character does not exist.")
		return
	character.global_position = character.tile_center_pos(target_tile)
