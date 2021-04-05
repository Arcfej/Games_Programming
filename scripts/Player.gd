extends Area2D

export var speed = 64
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2(0, -1)
		$AnimatedSprite.animation = "up"
	if Input.is_action_pressed("ui_left"):
		velocity = Vector2(-1, 0)
		$AnimatedSprite.animation = "left"
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2(0, 1)
		$AnimatedSprite.animation = "down"
	if Input.is_action_pressed("ui_right"):
		velocity = Vector2(1, 0)
		$AnimatedSprite.animation = "right"
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.set_frame(0)
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
