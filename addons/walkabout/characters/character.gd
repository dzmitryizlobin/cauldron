@tool
@icon("character.svg")
class_name WBCharacter
extends CharacterBody2D
## A character that can be controlled by events and behaviors and moves on a grid.


## Emitted when the character begins moving.
signal move_started()
## Emitted when the character reaches its target position.
signal move_finished()


enum Dir {LEFT, RIGHT, UP, DOWN}


const DIR_VECTORS: Dictionary[Dir, Vector2] = {
	Dir.LEFT: Vector2.LEFT,
	Dir.RIGHT: Vector2.RIGHT,
	Dir.UP: Vector2.UP,
	Dir.DOWN: Vector2.DOWN,
}


const DIR_ANIM_SUFFIXES: Dictionary[Dir, StringName] = {
	Dir.LEFT: &"_left",
	Dir.RIGHT: &"_right",
	Dir.UP: &"_up",
	Dir.DOWN: &"_down",
}


## Size of the grid the character is restricted to.
@export var tile_size: float = 16.0
## Speed the character walks at.
@export var walk_speed: float = 4.0
## Speed the character runs at.
@export var run_speed: float = 8.0

## Direction the character is facing.
@export var facing: Dir = Dir.DOWN

## Animation library for the character. [br]
## At a minimum, the [code]idle_*[/code] animations are required. [br]
## The following animations are used by default behavior: [br]
## [code]idle_[left,right,up,down][/code] [br]
## [code]walk_[left,right,up,down][/code] [br]
## [code]run_[left,right,up,down][/code] [br]
## [code]run_*[/code] will fallback to [code]walk_*[/code],
## which will fallback to [code]idle_*[/code]. [br]
## Addition custom animations may be provided to play on demand.
@export var animations: SpriteFrames:
	set(value):
		animations = value
		sprite.sprite_frames = animations

## Texture drawing offset of the animated sprite.
@export var sprite_offset: Vector2 = Vector2.ZERO:
	set(value):
		sprite_offset = value
		sprite.offset = sprite_offset


## True when the character is moving.
var moving: bool = false
## Whether the character is running.
var running: bool = false

## Tile position of the character on the grid.
var tile_position: Vector2i:
	get():
		return pos_to_tile(global_position)


var sprite: AnimatedSprite2D
var _next_pos: Vector2
var _playing_custom_animation: bool = false


func _init() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = animations
	add_child(sprite)


func _ready() -> void:
	global_position = closest_tile_center(global_position)
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return
	var col_shape := CollisionShape2D.new()
	col_shape.shape = RectangleShape2D.new()
	col_shape.shape.size = Vector2(tile_size - 2.0, tile_size - 2.0)
	add_child(col_shape)


func _physics_process(delta: float) -> void:
	if moving:
		var move_delta := (run_speed if running else walk_speed) * tile_size * delta
		global_position = global_position.move_toward(_next_pos, move_delta)
		if global_position == _next_pos:
			moving = false
			move_finished.emit()


func _process(delta: float) -> void:
	if moving:
		_playing_custom_animation = false
		var anims: Array[StringName] = [
			&"walk" + DIR_ANIM_SUFFIXES[facing],
			&"idle" + DIR_ANIM_SUFFIXES[facing]
		]
		if running:
			anims.push_front(&"run" + DIR_ANIM_SUFFIXES[facing])
		_try_animations(anims)
	elif not _playing_custom_animation:
		_try_animations([&"idle" + DIR_ANIM_SUFFIXES[facing]])


## Makes the character move one tile in the given direction. [br]
## If [param ignore_collision] is true, the character will not perform collision checks.
func start_move(dir: Dir, ignore_collision: bool = false) -> bool:
	if moving:
		return false
	
	facing = dir
	
	_next_pos = global_position + DIR_VECTORS[dir] * tile_size
	var col := move_and_collide(_next_pos - global_position, true)
	if col and not ignore_collision:
		return false
	
	moving = true
	move_started.emit()
	return true


## Plays a given custom animation from the animation set. [br]
## If [param reset_after] is [constant true], the animation will return to
## the default idle animation after it finishes.
func play_custom_animation(anim: StringName, reset_after: bool = false) -> void:
	_try_animations([anim])
	_playing_custom_animation = true
	
	if reset_after and not animations.get_animation_loop(anim):
		await sprite.animation_finished
		_playing_custom_animation = false

## Stops playing custom animation if one is currently playing.
func end_custom_animation() -> void:
	_playing_custom_animation = false


## Returns the closest tile center position to a given position in global coordinates.
func closest_tile_center(pos: Vector2) -> Vector2:
	var tile := pos - Vector2(tile_size, tile_size) * 0.5
	tile = tile.snappedf(tile_size)
	tile += Vector2(tile_size, tile_size) * 0.5
	return tile

## Returns the tile coordinates of a given position in global coordinates.
func pos_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i((global_position / Vector2(tile_size, tile_size)).floor())

## Returns the center position of a given tile in global coordinates.
func tile_center_pos(tile: Vector2i) -> Vector2:
	return (Vector2(tile) * Vector2(tile_size, tile_size)) + (Vector2(tile_size, tile_size) * 0.5)


func _try_animations(anims: Array[StringName]) -> void:
	for anim in anims:
		if animations.has_animation(anim):
			sprite.play(anim)
			return
