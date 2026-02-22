extends CharacterBody2D

@export var speed := 220.0
@export var stop_distance := 6.0

@onready var spr: AnimatedSprite2D = $AnimatedSprite2D

var target: Vector2
var has_target := false

# Порядок: E, SE, S, SW, W, NW, N, NE
# ЗАМЕНИ строки на точные имена твоих анимаций:
const DIR_ANIMS := [
	"walk_e",
	"walk_se",
	"walk_s",
	"walk_sw",
	"walk_w",
	"walk_nw",
	"walk_n",
	"walk_ne"
]

func _ready():
	target = global_position

func _unhandled_input(event):
	# ЛКМ: ставим цель (куда бежать)
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		target = get_global_mouse_position()
		has_target = true

func _physics_process(_dt):
	if not has_target:
		velocity = Vector2.ZERO
		_apply_anim(Vector2.ZERO)
		move_and_slide()
		return

	var to_target := target - global_position
	var dist := to_target.length()

	if dist <= stop_distance:
		has_target = false
		velocity = Vector2.ZERO
		_apply_anim(Vector2.ZERO)
	else:
		var dir := to_target / dist  # нормализованный вектор
		velocity = dir * speed
		_apply_anim(dir)

	move_and_slide()

func _apply_anim(dir: Vector2) -> void:
	if dir.length() < 0.001:
		spr.stop()
		return

	var a := dir.angle()
	var oct := int(round(a / (PI / 4.0))) & 7
	spr.play(DIR_ANIMS[oct])
