extends CharacterBody2D

@export var speed: float = 220.0
@export var stop_distance: float = 6.0
@export var direction_stickiness: float = 0.5
# ^ насколько “лениво” переключаем направление (в пикселях дистанции). 0.3–2.0 норм.

@onready var spr: AnimatedSprite2D = $AnimatedSprite2D

var target: Vector2
var has_target := false

const DIRS_RAW := [
	Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1),
	Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)
]

var DIRS: Array[Vector2] = []
var DIR_ANIMS: PackedStringArray

var last_dir_i: int = -1

func _ready() -> void:
	target = global_position

	DIRS.clear()
	for v in DIRS_RAW:
		DIRS.append(v.normalized())

	DIR_ANIMS = PackedStringArray([
		"walk_e","walk_se","walk_s","walk_sw",
		"walk_w","walk_nw","walk_n","walk_ne"
	])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		target = get_global_mouse_position()
		has_target = true

func _physics_process(dt: float) -> void:
	if not has_target:
		velocity = Vector2.ZERO
		_apply_anim(Vector2.ZERO)
		move_and_slide()
		return

	var to_target := target - global_position
	var dist := to_target.length()

	# Полная остановка
	if dist <= stop_distance:
		has_target = false
		last_dir_i = -1
		velocity = Vector2.ZERO
		_apply_anim(Vector2.ZERO)
		move_and_slide()
		return

	var step := speed * dt

	# ✅ SNAP: если за один шаг долетим — долетаем и стоп.
	if dist <= step + stop_distance:
		global_position = target
		has_target = false
		last_dir_i = -1
		velocity = Vector2.ZERO
		_apply_anim(Vector2.ZERO)
		return

	# Ищем лучший индекс направления
	var best_i := 0
	var best_next_dist := INF

	for i in range(DIRS.size()):
		var next_pos := global_position + DIRS[i] * step
		var next_dist := next_pos.distance_to(target)
		if next_dist < best_next_dist:
			best_next_dist = next_dist
			best_i = i

	# ✅ STICKINESS: не переключаемся на новое направление,
	# если оно не дает выигрыш больше порога.
	if last_dir_i != -1 and best_i != last_dir_i:
		var last_next_pos := global_position + DIRS[last_dir_i] * step
		var last_next_dist := last_next_pos.distance_to(target)

		# если новое направление лучше совсем чуть-чуть — остаёмся на старом
		if (last_next_dist - best_next_dist) < direction_stickiness:
			best_i = last_dir_i

	last_dir_i = best_i

	var dir := DIRS[best_i]
	velocity = dir * speed
	_apply_anim(dir)
	move_and_slide()

func _apply_anim(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		if spr.is_playing():
			spr.stop()
		return

	# В нашем случае dir всегда один из DIRS, но оставим безопасно
	var best_i := 0
	var best_dot := -INF
	var nd := dir.normalized()

	for i in range(DIRS.size()):
		var d := DIRS[i].dot(nd)
		if d > best_dot:
			best_dot = d
			best_i = i

	var anim: String = DIR_ANIMS[best_i]
	if spr.animation != anim or not spr.is_playing():
		spr.play(anim)
