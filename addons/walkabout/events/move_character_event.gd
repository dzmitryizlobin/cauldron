@icon("move_character_event.svg")
class_name WBMoveCharacterEvent
extends WBEvent
## Event that moves a character to the specified tile.


## Charcter to move.
@export var character: WBCharacter
## Tile position to move the target to.
@export var target_tile: Vector2i
## Whether the character should be running.
@export var run: bool = false
## Whether the character should move vertically or horizontally first.
@export var prefer_vertical: bool = false


func _perform() -> void:
	while character.tile_position != target_tile:
		if prefer_vertical:
			if character.tile_position.y < target_tile.y:
				character.start_move(WBCharacter.Dir.DOWN, true)
			elif character.tile_position.y > target_tile.y:
				character.start_move(WBCharacter.Dir.UP, true)
			elif character.tile_position.x < target_tile.x:
				character.start_move(WBCharacter.Dir.RIGHT, true)
			elif character.tile_position.x > target_tile.x:
				character.start_move(WBCharacter.Dir.LEFT, true)
		else:
			if character.tile_position.x < target_tile.x:
				character.start_move(WBCharacter.Dir.RIGHT, true)
			elif character.tile_position.x > target_tile.x:
				character.start_move(WBCharacter.Dir.LEFT, true)
			elif character.tile_position.y < target_tile.y:
				character.start_move(WBCharacter.Dir.DOWN, true)
			elif character.tile_position.y > target_tile.y:
				character.start_move(WBCharacter.Dir.UP, true)
		await character.move_finished
