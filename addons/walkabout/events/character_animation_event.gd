@icon("character_animation_event.svg")
class_name WBCharacterAnimationEvent
extends WBEvent
## Event that makes a character play a specific animation.


## Character to animate.
@export var character: WBCharacter
## Animation to play.
@export var animation: StringName
## Number of times to let animation loop if the animation loops.
@export var loops: int = 1


func _perform() -> void:
	if not character:
		push_error("Target character does not exist.")
		return
	if not character.animations.has_animation(animation):
		push_error("The specified animation does not exist in this character.")
		return
	
	character.play_custom_animation(animation)
	if character.animations.get_animation_loop(animation):
		var remaining_loops := loops
		while remaining_loops > 0:
			await character.sprite.animation_looped
			remaining_loops -= 1
	else:
		await character.sprite.animation_finished
	character.end_custom_animation()
