extends KinematicBody2D

# The base speed of the player
const BASE_SPEED = 30

func _physics_process(delta):
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
	
	# Normalize velocity and multiply it with speed and the current scale of the map
	if velocity.length() > 0:
		velocity = velocity.normalized() * BASE_SPEED * Global.map_scale
	
	# Move the player but loose inertia if no input is given
	move_and_collide(velocity * delta, false)

# Call when the player enters a new map.
func enter_map(new_position : Vector2):
	position = new_position

# Area collision checks
func _on_Area2D_area_entered(area):
	if area is Entrance:
		Global.entrance_reached(area.get_id())
