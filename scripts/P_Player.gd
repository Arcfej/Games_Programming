extends Area2D

export var speed = 50
var movement_boundaries = Rect2(0, 0, 0, 0) setget set_movement_boundaries, get_movement_boundaries
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
	
	var new_position = velocity * delta
	position.x = clamp(
		position.x + new_position.x,
		movement_boundaries.position.x,
		movement_boundaries.end.x)
	position.y = clamp(
		position.y + new_position.y,
		movement_boundaries.position.y,
		movement_boundaries.end.y)

func set_movement_boundaries(boundaries):
	if boundaries is Rect2:
		movement_boundaries = boundaries
	else:
		printerr("Movement boundaries not set by a Rect2 for player")

func get_movement_boundaries():
	return movement_boundaries
