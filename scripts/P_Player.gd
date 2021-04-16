extends Area2D

# The speed of the player
export var speed = 50
# Movement boundaries.
# If not set, the player is not allowed to move outside of it's starting tile.
var movement_boundaries = Rect2(0, 0, 0, 0) setget set_movement_boundaries, get_movement_boundaries
# Collision object and shape of the player.
# Used for setting the movement boundaries on the map.
onready var collision_object = $CollisionShape2D setget , get_collision_object
onready var collision_shape = collision_object.get_shape() setget , get_collision_shape
# Indicatior if the player just placed on the map after it's been loaded.
# If true, moving back to the previous map is disabled for two-directional entrances
var just_entered_map = false

func _process(delta):
	# TODO storing the last direction in an enum,
	# so always react to new key-presses, not in the order of up-left-right-down
	# Getting user inputs for movement and set initial velocity
	var velocity = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2(0, -1)
	if Input.is_action_pressed("ui_left"):
		velocity = Vector2(-1, 0)
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2(0, 1)
	if Input.is_action_pressed("ui_right"):
		velocity = Vector2(1, 0)
	
	# Normalize velocity and multiply it with speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	# Calculate the new position then clamp it inside the movement boundary
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
	# If the player just entered the map set up a oneshot signal
	# when the player leaves the entrance it arrived at
	if just_entered_map:
		for area in get_overlapping_areas():
			# Only connect the signal if it's not been set yet
			if !is_connected("area_exited", self, "_on_Player_area_exited"):
				connect("area_exited", self, "_on_Player_area_exited", [], CONNECT_ONESHOT)

# Set movement boundaries on movement with a Rect2
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

# Call when the player enters a new map.
# Travelling back will be disabled temporarily till starting position is leaved
func enter_map(new_position, is_through_2way_entrance):
	position = new_position
	just_entered_map = is_through_2way_entrance

# Collision checks
func _on_Player_area_entered(area):
	if just_entered_map: return
	if area is Entrance:
		Global.entrance_reached(area.get_id())

func _on_Player_area_exited(area):
	just_entered_map = false;
