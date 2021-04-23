extends KinematicBody2D

enum State {IDLE, PATROLING, ALERT}

# Seeing distance in tiles
export(int) var seeing_distance
# Seeing angle in degree (180 means the guard can see everything in the front and both sides
export(int, EXP, 0, 90) var seeing_angle
# The direction the guard faces
export(Vector2) var seeing_direction
# The speed of the guard
const BASE_SPEED = 30

# The state of the guard (see State enum)
export(State) var state = State.IDLE

# An array which describes a route when the guard's patroling
var route: Array
# Indicate what stage the guard is at on its patrol
var route_index = 0

# The movement the guard does while patroling
var patroling_state = Movement.Type.MOVE
# Measure time-based movements
var patroling_timer = 0

func _ready():
	# Don't allow to collide with self
	$RayCast2D.add_exception(self)

func _physics_process(delta):
	# Check if guard can see player
	var enemy_to_player = PPlayer.position - position
	# TODO delete update() after testing
	update()
	# If the player in seeing distance check further
	if enemy_to_player.length() <= seeing_distance * Global.tile_size:
		# Check if the player is in the guard's angle of vision
		if abs(rad2deg(enemy_to_player.angle_to(seeing_direction.normalized()))) < seeing_angle / 2:
			# TODO improve raycasting by casting it as a tangent vector instead of to the middle
			$RayCast2D.cast_to = enemy_to_player
			# Ray-cast to the player and check if nothing obscures the guard's view
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider().get_parent() == PPlayer:
				# TODO reset level
				print("Busted")
	
	# Patrolling the guard
	if state == State.PATROLING:
		patrol(delta)

# Moves the guard on its patrol route
func patrol(delta):
	# The step the guard is currently taking / will take
	var step = route[route_index]
	# Set the state according to the step
	patroling_state = step.type
	
	# Check if the guard is standing and the required time ellapsed
	if patroling_state == Movement.Type.STAND and patroling_timer > step.duration / 1000.0:
		# Go to the next step on patroling and reset the timer
		route_index += 1
		patroling_timer = 0
	elif patroling_state == Movement.Type.STAND:
		# Increment the timer if the guard is in standing mode
		patroling_timer += delta
	else:
		# 
		match step.type:
			# Move the guard on it's road
			Movement.Type.MOVE:
				var new_position = step.destination_or_direction * Global.tile_size
				move_and_collide((new_position - position).normalized() * delta * Global.map_scale.length() * BASE_SPEED, false)
				# Check if the guard reached it's destination (with an error margin)
				if (new_position - position).length() < 1:
					# Go to the next step on its patrol
					route_index += 1
			# Change the direction toward the guard sees and go to the next step
			Movement.Type.CHANGE_DIRECTION:
				seeing_direction = step.destination_or_direction
				route_index += 1
	
	# Check if the route is ended, then start the patrol again from the beginning
	if route_index >= route.size(): route_index = 0

func _draw():
	# For debugging, making the guard's vision visible
	var from = Vector2(Global.tile_size / 2, Global.tile_size / 2)
	draw_line(from, seeing_direction * seeing_distance * Global.tile_size + from, Color.yellow, 1)
	draw_line(from, seeing_direction.rotated(deg2rad(seeing_angle / 2)) * seeing_distance * Global.tile_size + from, Color.yellow, 1)
	draw_line(from, seeing_direction.rotated(-deg2rad(seeing_angle / 2)) * seeing_distance * Global.tile_size + from, Color.yellow, 1)
	draw_line(from, to_local(PPlayer.global_position) + from, Color.red, 1)
