extends KinematicBody2D

const BASE_SPEED = 30
# The speed of the player
export(int) var speed = BASE_SPEED
# Indicatior if the player just placed on the map after it's been loaded.
# If true, moving back to the previous map is disabled for two-directional entrances
var just_entered_map = false

func _physics_process(delta):
	# If the player just entered the map set up a oneshot signal
	# when the player leaves the entrance it arrived at
	if just_entered_map:
		for area in $Area2D.get_overlapping_areas():
			# Only connect the signal if it's not been set yet
			if !$Area2D.is_connected("area_exited", self, "_on_Player_area_exited"):
				$Area2D.connect("area_exited", self, "_on_Player_area_exited", [], CONNECT_ONESHOT)
	
	# Getting user input for 'action'
	# TODO check interactives in all 4 directions and pop up a menu to chose if there are more than one
	if Input.is_action_just_pressed("ui_accept"):
		for body in $InteractiveArea.get_overlapping_bodies():
			if body.is_in_group("interactive"):
				body.interact_with()
	
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
func enter_map(new_position : Vector2, is_through_2way_entrance : bool, scale : Vector2):
	position = new_position
	just_entered_map = is_through_2way_entrance
	speed = BASE_SPEED * scale.length()

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
