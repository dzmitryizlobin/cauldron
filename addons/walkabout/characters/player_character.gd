@tool
@icon("player_character.svg")
class_name WBPlayerCharacter
extends WBCharacter
## A character controlled directly by the player.


## Whether the character will react to player input.
@export var controllable: bool = true
## Time to wait after turning before the character will start moving.
@export var turn_walk_time: float = 0.25
## Collision mask for interactive objects.
## If a collision is detected, [method interact] will be called on the target object if it exists.
@export_flags_2d_physics var interact_mask: int:
	set(value):
		interact_mask = value
		_interact_raycast.collision_mask = interact_mask

@export_group("Input Actions", "input_")
@export var input_left: StringName = &"ui_left"
@export var input_right: StringName = &"ui_right"
@export var input_up: StringName = &"ui_up"
@export var input_down: StringName = &"ui_down"
@export var input_interact: StringName = &"ui_accept"
@export var input_run: StringName = &"ui_cancel"


var _interact_raycast: RayCast2D
var _turn_cooldown: float = 0.0


func _init() -> void:
	super._init()
	
	move_finished.connect(_check_move_input)
	
	_interact_raycast = RayCast2D.new()
	_interact_raycast.enabled = false
	_interact_raycast.collide_with_areas = true
	_interact_raycast.hit_from_inside = true
	_interact_raycast.add_exception(self)
	add_child(_interact_raycast)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_turn_cooldown -= delta
	running = Input.is_action_pressed(input_run)
	if not moving:
		_check_move_input(true)
	super._physics_process(delta)


## Enables player control of the character.
func enable_control() -> void:
	controllable = true

## Disables player control of the character.
func disable_control() -> void:
	controllable = false


func _check_move_input(check_turn_cooldown: bool = false) -> void:
	if not controllable:
		return
	
	if Input.is_action_pressed(input_left):
		_try_move(Dir.LEFT, check_turn_cooldown)
	elif Input.is_action_pressed(input_right):
		_try_move(Dir.RIGHT, check_turn_cooldown)
	elif Input.is_action_pressed(input_up):
		_try_move(Dir.UP, check_turn_cooldown)
	elif Input.is_action_pressed(input_down):
		_try_move(Dir.DOWN, check_turn_cooldown)
	elif Input.is_action_just_pressed(input_interact):
		_try_interact()


func _try_move(dir: Dir, check_turn_cooldown: bool) -> void:
	if facing != dir:
		_turn_cooldown = turn_walk_time
		if running:
			_turn_cooldown *= 0.5
	facing = dir
	if check_turn_cooldown and _turn_cooldown >= 0.0:
		return
	start_move(dir)


func _try_interact() -> void:
	_interact_raycast.target_position = DIR_VECTORS[facing] * tile_size
	_interact_raycast.force_raycast_update()
	if _interact_raycast.is_colliding():
		var interactive := _interact_raycast.get_collider()
		if interactive.has_method(&"interact"):
			interactive.interact()
