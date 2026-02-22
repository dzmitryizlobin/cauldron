@tool
@icon("wander_behavior.svg")
class_name WBWanderBehavior
extends WBCharacterBehavior
## A behavior that makes a character randomly wander around within a specified area.


## Rectangle enclosing the tiles the character is allowed to move to.
@export var territory: Rect2i
## Minimum distance to travel in one "burst".
@export var min_distance: int
## Maximum distance to travel in one "burst".
@export var max_distance: int
## Minimum time to idle after finishing a "burst".
@export_custom(0, "suffix:s") var min_idle: float
## Maximum time to idle after finishing a "burst".
@export_custom(0, "suffix:s") var max_idle: float
## Whether the character should run.
@export var run: bool = false


func _init() -> void:
	if Engine.is_editor_hint():
		add_child(DebugView.new(self))


func _activate() -> void:
	if character:
		_do_move()


func _do_move() -> void:
	if not active:
		return
	
	var remaining_distance: int = randi_range(min_distance, max_distance)
	var dir: WBCharacter.Dir = WBCharacter.Dir.values().pick_random()
	
	while remaining_distance > 0:
		while not territory.has_point(character.tile_position + Vector2i(WBCharacter.DIR_VECTORS[dir])):
			dir = WBCharacter.Dir.values().pick_random()
		character.running = run
		character.start_move(dir)
		if character.moving:
			await character.move_finished
		remaining_distance -= 1
	
	await create_tween().tween_interval(randf_range(min_idle, max_idle)).finished
	_do_move()


class DebugView extends Node2D:
	var behavior: WBWanderBehavior
	
	func _init(p_behavior: WBWanderBehavior) -> void:
		behavior = p_behavior
	
	func _process(delta: float) -> void:
		if Engine.get_frames_drawn() % 60 == 0:
			queue_redraw()
	
	func _draw() -> void:
		if not behavior.character:
			return
		
		var position := to_local(Vector2(behavior.territory.position) * behavior.character.tile_size)
		var size := Vector2(behavior.territory.size) * behavior.character.tile_size
		
		var color := Color.MEDIUM_PURPLE
		var width := -1.0
		var selection := EditorInterface.get_selection()
		if behavior in selection.get_selected_nodes():
			color = Color.PURPLE
			width = 2.0
		draw_rect(
			Rect2(position, size),
			color, false, width
		)
