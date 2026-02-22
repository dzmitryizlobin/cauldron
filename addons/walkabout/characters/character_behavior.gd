@tool
@icon("character_behavior.svg")
class_name WBCharacterBehavior
extends Node
## Controls/puppets a parent character.


## Whether the behavior is currently active.
@export var active: bool:
	set(value):
		var last_value := active
		active = value
		if active:
			if not is_node_ready():
				await ready
			for child in get_parent().get_children():
				if child != self and child is WBCharacterBehavior:
					child.active = false
		if active:
			_activate()
		else:
			_deactivate()


## The character being controlled.
var character: WBCharacter:
	get():
		return get_parent() as WBCharacter


## Enables the behavior.
func enable() -> void:
	active = true

## Disables the behavior.
func disable() -> void:
	active = false


func _activate() -> void:
	pass

func _deactivate() -> void:
	pass
