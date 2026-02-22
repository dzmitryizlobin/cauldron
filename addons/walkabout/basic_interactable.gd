@tool
class_name WBBasicInteractive
extends StaticBody2D
## Collision object that emits a signal when interacted with by a player character.


## Emitted when a player character interacts with this object.
signal interacted()


func _init() -> void:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return
	var col_shape := CollisionShape2D.new()
	col_shape.shape = RectangleShape2D.new()
	col_shape.shape.size = Vector2(8.0, 8.0)
	add_child(col_shape)


func interact() -> void:
	interacted.emit()
