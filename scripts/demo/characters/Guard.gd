extends RigidBody2D

export var speed = 64

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_DirectionChangeTimer_timeout():
	match randi() % 4:
		0:
			linear_velocity = Vector2(speed, 0)
			$AnimatedSprite.set_animation("right")
		1:
			linear_velocity = Vector2(0, speed)
			$AnimatedSprite.set_animation("down")
		2:
			linear_velocity = Vector2(-speed, 0)
			$AnimatedSprite.set_animation("left")
		3:
			linear_velocity = Vector2(0, -speed)
			$AnimatedSprite.set_animation("up")
