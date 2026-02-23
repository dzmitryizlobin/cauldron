extends Node2D

@export var light_map_path: NodePath
@export var player_path: NodePath

@export var radius_px: float = 1200.0
@export var update_only_on_cell_change := true

# Если у тебя один тайл в атласе — оставь так:
@export var atlas_coords: Array[Vector2i] = [Vector2i(0, 0)]
@export var source_id: int = 0

@onready var light_map: TileMapLayer = get_node(light_map_path)
@onready var player: Node2D = get_node(player_path)

var filled := {} # Dictionary: cell(Vector2i) -> atlas_coord(Vector2i)
var last_center_cell: Vector2i = Vector2i(999999, 999999)
var last_r_cells: int = -1

func _process(_dt):
	_update_light()

func set_radius(new_radius_px: float):
	radius_px = max(0.0, new_radius_px)
	_update_light(true)

func _update_light(force := false):
	# TileMapLayer знает tile_set и tile_size так же
	var cell_size: Vector2i = light_map.tile_set.tile_size
	var r_cells := int(ceil(radius_px / float(cell_size.x))) + 1

	var center_world: Vector2 = player.global_position

	# В TileMapLayer есть local_to_map, но ему нужны локальные координаты слоя:
	var center_local: Vector2 = light_map.to_local(center_world)
	var center_cell: Vector2i = light_map.local_to_map(center_local)

	if update_only_on_cell_change and not force:
		if center_cell == last_center_cell and r_cells == last_r_cells:
			return

	last_center_cell = center_cell
	last_r_cells = r_cells

	# 1) какие клетки должны быть заполнены
	var want := {}
	for y in range(-r_cells, r_cells + 1):
		for x in range(-r_cells, r_cells + 1):
			if x * x + y * y <= r_cells * r_cells:
				var c := center_cell + Vector2i(x, y)
				want[c] = true

	# 2) удалить лишнее
	for c in filled.keys():
		if not want.has(c):
			light_map.erase_cell(c)
			filled.erase(c)

	# 3) добавить недостающее
	for c in want.keys():
		if not filled.has(c):
			var ac := atlas_coords[randi() % atlas_coords.size()]
			# В TileMapLayer set_cell без layer-индекса:
			light_map.set_cell(c, source_id, ac)
			filled[c] = ac
