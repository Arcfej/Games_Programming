extends StaticBody2D
class_name Door

export var id = -1
export var is_open = false
var in_change = false

func _ready():
	$AnimatedSprite.frame = 1 if is_open else 0

func _process(delta):
	$CollisionShape2D.disabled = true if is_open else false

func switch():
	if is_open:
		close()
	else:
		open()

func open():
	$AnimatedSprite.play("default")

func close():
	$AnimatedSprite.play("default", true)


func _on_AnimatedSprite_animation_finished():
	is_open = !is_open
	$AnimatedSprite.stop()
