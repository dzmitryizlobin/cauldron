@tool
@icon("path_behavior.svg")
class_name WBPathBehavior
extends WBCharacterBehavior
## A behavior that makes a character walk along a specified path,
## looping when they reach the end.


## List of points to walk to.
@export var points: Array[Vector2i]
## Whether the character should be running.
@export var run: bool = false


var _current_point: int


func _init() -> void:
	if Engine.is_editor_hint():
		add_child(DebugView.new(self))


func _activate() -> void:
	_do_move()


func _do_move() -> void:
	if not active:
		return
	
	if character.tile_position == points[_current_point]:
		_current_point = posmod(_current_point + 1, points.size())
	
	var point := points[_current_point]
	if character.tile_position.x < point.x:
		character.start_move(WBCharacter.Dir.RIGHT)
	elif character.tile_position.x > point.x:
		character.start_move(WBCharacter.Dir.LEFT)
	elif character.tile_position.y < point.y:
		character.start_move(WBCharacter.Dir.DOWN)
	elif character.tile_position.y > point.y:
		character.start_move(WBCharacter.Dir.UP)
	
	if character.moving:
		await character.move_finished
	
	_do_move()


class DebugView extends Node2D:
	var behavior: WBPathBehavior
	
	func _init(p_behavior: WBPathBehavior) -> void:
		behavior = p_behavior
	
	func _process(delta: float) -> void:
		if Engine.get_frames_drawn() % 60 == 0:
			queue_redraw()
	
	func _draw() -> void:
		if not behavior.character:
			return
		
		var color := Color.MEDIUM_PURPLE
		var width := -1.0
		var selection := EditorInterface.get_selection()
		if behavior in selection.get_selected_nodes():
			color = Color.PURPLE
			width = 2.0
		
		var last_point := to_local(behavior.character.closest_tile_center(behavior.character.global_position))
		for point in behavior.points + [behavior.points[0]]:
			var current_point := to_local(behavior.character.tile_center_pos(point))
			draw_line(last_point, Vector2(current_point.x, last_point.y), color, width)
			draw_line(Vector2(current_point.x, last_point.y), current_point, color, width)
			var arrow_dir := current_point.direction_to(Vector2(current_point.x, last_point.y))
			if arrow_dir.is_zero_approx():
				arrow_dir = current_point.direction_to(last_point)
			draw_line(current_point, current_point + arrow_dir.rotated(deg_to_rad(45.0)) * 8.0, color, width)
			draw_line(current_point, current_point + arrow_dir.rotated(deg_to_rad(-45.0)) * 8.0, color, width)
			last_point = current_point
