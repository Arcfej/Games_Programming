extends Area2D

export var speed = 50
var movement_boundaries = Rect2(0, 0, 0, 0) setget set_movement_boundaries, get_movement_boundaries
var screen_size
onready var collision_object = $CollisionShape2D setget , get_collision_object
onready var collision_shape = collision_object.get_shape() setget , get_collision_shape
var just_entered_map = false

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

func _physics_process(delta):
	if just_entered_map:
		for area in get_overlapping_areas():
			if !is_connected("area_exited", self, "_on_Player_area_exited"):
				connect("area_exited", self, "_on_Player_area_exited", [], CONNECT_ONESHOT)

func set_movement_boundaries(boundaries):
	if boundaries is Rect2:
		movement_boundaries = boundaries
	else:
		printerr("Movement boundaries not set by a Rect2 for player")

func get_movement_boundaries():
	return movement_boundaries

func get_collision_object():
	return collision_object

func get_collision_shape():
	return collision_shape

func enter_map(new_position):
	position = new_position
	just_entered_map = true

func _on_Player_area_entered(area):
	if just_entered_map: return
	if area is Entrance:
		Global.entrance_reached(area.get_id())

func _on_Player_area_exited(area):
	just_entered_map = false;
