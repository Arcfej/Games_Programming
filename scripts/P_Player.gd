extends KinematicBody2D

# The speed of the player
export var speed = 128
# Indicatior if the player just placed on the map after it's been loaded.
# If true, moving back to the previous map is disabled for two-directional entrances
var just_entered_map = false

func _physics_process(delta):
	# If the player just entered the map set up a oneshot signal
	# when the player leaves the entrance it arrived at
	if just_entered_map:
		print($Area2D.get_overlapping_areas().size())
		for area in $Area2D.get_overlapping_areas():
			# Only connect the signal if it's not been set yet
			if !$Area2D.is_connected("area_exited", self, "_on_Player_area_exited"):
				$Area2D.connect("area_exited", self, "_on_Player_area_exited", [], CONNECT_ONESHOT)
	
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
	
	# Move the player but loose inertia if no input is given
	move_and_collide(velocity * delta, false)

# Call when the player enters a new map.
# Travelling back will be disabled temporarily till starting position is leaved
func enter_map(new_position, is_through_2way_entrance):
	position = new_position
	just_entered_map = is_through_2way_entrance

# Leaving an entrance if the starting position on the map is an entrance.
# Reenable area detection
func _on_Player_area_exited(area):
	if area is Entrance:
		just_entered_map = false

# Area collision checks
func _on_Area2D_area_entered(area):
	if just_entered_map: return
	if area is Entrance:
		Global.entrance_reached(area.get_id())
