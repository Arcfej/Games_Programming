extends Area2D

export var speed = 64
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2(0, -1)
	if Input.is_action_pressed("ui_left"):
		velocity = Vector2(-1, 0)
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2(0, 1)
	if Input.is_action_pressed("ui_right"):
		velocity = Vector2(1, 0)
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	var parent_position = get_parent().get_position()
	position.x = clamp(
		position.x,
		-parent_position.x,
		screen_size.x - parent_position.x - $Sprite.texture.get_width())
	position.y = clamp(
		position.y,
		-parent_position.y,
		screen_size.y - parent_position.y - $Sprite.texture.get_height())
