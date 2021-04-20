extends StaticBody2D
class_name Switch

signal switch_doors(door_ids)

# The id of the doors the switch changes
export(Array, int) var connected_door_ids = []
# The state of the switch
var on_right = false

func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.stop()

# Called if the switch is pushed
func interact_with():
	$AnimatedSprite.play("default", on_right)
	on_right = !on_right
	for door_id in connected_door_ids:
		emit_signal("switch_doors", door_id)
