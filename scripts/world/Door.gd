extends StaticBody2D
class_name Door

export (int) var id = -1 setget , get_id
export var is_open = false
var in_change = false

func _ready():
	$AnimatedSprite.frame = 1 if is_open else 0
	$CollisionShape2D.disabled = true if is_open else false

func switch():
	if is_open:
		close()
	else:
		open()

func open():
	$AnimatedSprite.play("default")
	$CollisionShape2D.disabled = true

func close():
	$AnimatedSprite.play("default", true)
	$CollisionShape2D.disabled = false

# Play the animation only once
func _on_AnimatedSprite_animation_finished():
	is_open = !is_open
	$AnimatedSprite.stop()

func get_id():
	return id
