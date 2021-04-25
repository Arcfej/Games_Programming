extends KinematicBody2D
class_name Guard

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

# PATROL
# An array which describes a route when the guard's patroling
var patrol_route: Array
# Indicate what stage the guard is at on its patrol
var patrol_index = 0
# The movement the guard does while patroling
var patroling_state = Movement.Type.MOVE
# Measure time-based movements
var patroling_timer = 0

# ALERT
# The place the guard will investigate in TileMap coordinates
var to_investigate: Vector2
# The route towards the point to investigate in TileMap coordinates
var investigate_route: PoolVector2Array
# Indicate where the guard is at on it's route
var investigate_index = 0

func _ready():
	# Don't allow to collide with self
	$RayCast2D.add_exception(self)

func _process(delta):
	# Indicate that the guard is alert or not
	$Alert.visible = true if state == State.ALERT else false

func _physics_process(delta):
	# Check if guard can see player
	var enemy_to_player = PPlayer.position - position
	# TODO delete update() after testing
	update()
	# If the player in seeing distance check further
	if enemy_to_player.length_squared() <= pow(seeing_distance * Global.tile_size, 2):
		# Check if the player is in the guard's angle of vision
		if abs(rad2deg(enemy_to_player.angle_to(seeing_direction.normalized()))) < seeing_angle / 2:
			# TODO improve raycasting by casting it as a tangent vector instead of to the middle
			$RayCast2D.cast_to = enemy_to_player
			# Ray-cast to the player and check if nothing obscures the guard's view
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider().get_parent() == PPlayer:
				# TODO reset level
				print("Busted")
	
	# Patrolling the guard
	match state:
		State.PATROLING:
			patrol(delta)
		State.ALERT:
			investigate(delta)

# Moves the guard on its patrol route
func patrol(delta):
	# The step the guard is currently taking / will take
	var step = patrol_route[patrol_index]
	# Set the state according to the step
	patroling_state = step.type
	
	# Check if the guard is standing and the required time ellapsed
	if patroling_state == Movement.Type.STAND and patroling_timer > step.duration / 1000.0:
		# Go to the next step on patroling and reset the timer
		patrol_index += 1
		patroling_timer = 0
	elif patroling_state == Movement.Type.STAND:
		# Increment the timer if the guard is in standing mode
		patroling_timer += delta
	else:
		match step.type:
			# Move the guard on it's road
			Movement.Type.MOVE:
				var new_position = step.destination_or_direction * Global.tile_size
				move_and_collide((new_position - position).normalized() * delta * Global.map_scale * BASE_SPEED, false)
				# Check if the guard reached it's destination (with an error margin)
				if (new_position - position).length_squared() < 1:
					# Go to the next step on its patrol
					patrol_index += 1
			# Change the direction toward the guard sees and go to the next step
			Movement.Type.CHANGE_DIRECTION:
				seeing_direction = step.destination_or_direction
				patrol_index += 1
	
	# Check if the route is ended, then start the patrol again from the beginning
	if patrol_index >= patrol_route.size(): patrol_index = 0

# Investigate if the guard is on alert
func investigate(delta):
	# Return if there's no route attached to the ALERT state
	if investigate_route.size() == 0: return
	
	var next_point = investigate_route[investigate_index] * Global.tile_size # This row is repeated below
	# If the next point on the route reached, increment the index
	if (next_point - position).length_squared() < 1:
		investigate_index += 1
		next_point = investigate_route[investigate_index] * Global.tile_size
	# If the destination reached, move to IDLE state and return
	if investigate_index == investigate_route.size() - 1:
		state = State.IDLE
		return
	# Move the guard towards the next point
	var velocity = (next_point - position).normalized()
	move_and_collide(velocity.round() * Global.map_scale * BASE_SPEED * delta, false)

# Make the guard alert
func make_alert(location: Vector2, path: PoolVector2Array):
	state = State.ALERT
	to_investigate = location
	investigate_index = 0
	investigate_route = path

func _draw():
	# TODO delete after testing
	# For debugging, making the guard's vision visible
	var from = Vector2(Global.tile_size / 2, Global.tile_size / 2)
	draw_line(from, seeing_direction * seeing_distance * Global.tile_size + from, Color.yellow, 1)
	draw_line(from, seeing_direction.rotated(deg2rad(seeing_angle / 2)) * seeing_distance * Global.tile_size + from, Color.yellow, 1)
	draw_line(from, seeing_direction.rotated(-deg2rad(seeing_angle / 2)) * seeing_distance * Global.tile_size + from, Color.yellow, 1)
	draw_line(from, to_local(PPlayer.global_position) + from, Color.red, 1)
