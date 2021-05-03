extends KinematicBody2D
class_name Guard

enum State {IDLE, PATROLING, ALERT}

# Seeing distance in tiles
export(int) var seeing_distance: int
# Seeing angle in degree (180 means the guard can see everything in the front and both sides
export(int, EXP, 0, 90) var seeing_angle: int
# The direction the guard faces
var seeing_direction = Vector2(0, 1)
# A close detection radius in tiles where the guard can detect the player outside it's seeing angle
export(float, 100) var close_detection_radius

# The speed of the guard
const BASE_SPEED = 30

# The state of the guard (see State enum)
export(State) var state = State.IDLE

# PATROL
# A Movement array which describes a route when the guard's patroling
export(Array) var patrol_steps
# Indicate what stage the guard is at on its patrol
var patrol_step_index = 0
# The movement the guard does while patroling
var patroling_state = Movement.Type.MOVE
# The route for Movement.Type.MOVE steps
var patrol_route: PoolVector2Array
# An index used to know where the guard is when doint Movement.Type.MOVE
# If -1, it indicates that a new patrol route have to be calculated
var patrol_move_index = -1
# Measure time-based movements
var patroling_timer = 0

# ALERT
# The place the guard will investigate in TileMap coordinates
var to_investigate: Vector2
# The route towards the point to investigate in TileMap coordinates
var investigate_route: PoolVector2Array
# Indicate where the guard is at on it's route
var investigate_index = 0

export(PoolIntArray) var key

func _process(delta):
	# Indicate that the guard is alert or not
	$Alert.visible = true if state == State.ALERT else false

func _physics_process(delta):
	# Check if guard can see player (correct the coordinates to point to the player's center)
	var enemy_to_player = to_local(PPlayer.to_global(Vector2(Global.tile_size / 2, Global.tile_size / 2)))
	# TODO delete update() after testing
	update()
	# If the player in seeing distance check further
	if enemy_to_player.length_squared() <= pow(seeing_distance * Global.tile_size, 2):
		# Check if the player is in the guard's angle of vision or in close detection radius
		if abs(rad2deg(enemy_to_player.angle_to(seeing_direction.normalized()))) < seeing_angle / 2.0 or \
				enemy_to_player.length_squared() < pow(close_detection_radius * Global.tile_size, 2):
			# TODO improve raycasting by casting it as a tangent vector instead of to the middle
			$RayCast2D.enabled = true
			$RayCast2D.cast_to = enemy_to_player
			# Ray-cast to the player and check if nothing obscures the guard's view
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider().get_parent() == PPlayer:
				Global.player_seen()
		else:
			$RayCast2D.enabled = false
	
	# Chose behaviour based on state
	match state:
		State.PATROLING:
			patrol(delta)
		State.ALERT:
			investigate_index = _move_on_route(delta, investigate_route, investigate_index, false)
			# If the destination reached, move back to PATROLING
			if investigate_index == investigate_route.size():
				state = State.PATROLING

# Moves the guard on its patrol route
func patrol(delta):
	if patrol_steps.size() == 0: return
	# The step the guard is currently taking / will take
	var step: Movement
	step = patrol_steps[patrol_step_index]
	# Set the state according to the step
	patroling_state = step.type
	
	match patroling_state:
		Movement.Type.STAND:
			# Check if the guard is standing and the required time ellapsed
			if patroling_timer > step.duration / 1000.0:
				# Go to the next step on patroling and reset the timer
				patrol_step_index += 1
				patroling_timer = 0
			else:
				# Increment the timer if the guard is in standing mode
				patroling_timer += delta
		Movement.Type.MOVE:
			# Calculate the route for the movement if it's just started
			if patrol_move_index == -1:
				patrol_route = Global.find_simple_path(Global.local_to_tile_map(position), step.destination_or_direction, false)
				patrol_move_index = 0
			# Move the guard on it's road
			patrol_move_index = _move_on_route(delta, patrol_route, patrol_move_index, false)
			# If the destination reached, reset the patrol move fields and go to the next step
			if patrol_move_index == patrol_route.size():
				patrol_move_index = -1
				patrol_route = PoolVector2Array([])
				patrol_step_index += 1
		# Change the direction toward the guard sees and go to the next step
		Movement.Type.CHANGE_DIRECTION:
			_change_direction(step.destination_or_direction)
			patrol_step_index += 1

	# Check if the route is ended, then start the patrol again from the beginning
	if patrol_step_index >= patrol_steps.size(): patrol_step_index = 0

# Move the guard along a given route.
#	delta:		the time ellapsed since the last physics frame
#	route		the route to follow in tile-map coordinates
#	index		where the guard is on this route
#	repeat		true, if the route have to be repeated from the beginning after the end is reached
func _move_on_route(delta, route: PoolVector2Array, index: int, repeat: bool) -> int:
	# Return if there's no route
	if route.size() == 0: return index
	
	var next_point = Global.tile_map_to_local(route[index]) # This row is repeated below
	# Calculate the distance. Add half of tile-size, because the guard is centered
	var distance = next_point - position + Vector2(Global.tile_size / 2, Global.tile_size / 2)  # This row is repeated below
	# If the next point on the route reached, increment the index
	if distance.length_squared() < 1:
		index += 1
		# Update next point and distance if it wasn't the last one
		if index < route.size():
			next_point = Global.tile_map_to_local(route[index])
			distance = next_point - position + Vector2(Global.tile_size / 2, Global.tile_size / 2)
	
	# Check if the end of the route is reached
	if index == route.size():
		# If the route have to be repeated, reset index
		if repeat: index = 0
		return index
	
	# Move the guard towards the next point if it's facing that direction or change the direction
	# Use the normalized distance as velocity
	if abs(seeing_direction.rotated(transform.get_rotation()).angle_to(distance)) < deg2rad(4):
		# Move the guard and check if a collision's occured
		var collision: KinematicCollision2D = move_and_collide(distance.normalized() * Global.map_scale * BASE_SPEED * delta, false)
		if collision:
			var collider = collision.get_collider()
			# If the collider object is the next step on the route, it means the guard has to interact with it
			var pos = Global.global_to_tile_map(collider.global_position)
			if Global.global_to_tile_map(collider.global_position) == route[index]:
				# If it's a door and the guard has a key for it, open the door
				if collider is Door:
					for id in key:
						if collider.id == id:
							collider.open()
							break
				# If it's a switch, switch it
				if collider is Switch:
					collider.interact_with()
					index += 1
	else:
		_change_direction(distance.normalized())
	
	return index

# Change the direction the guard is facing
func _change_direction(direction: Vector2):
	# Change the rotation of the guard to match the moving direction
	match round(direction.x):
		1.0: match round(direction.y):
			-1.0: rotation = deg2rad(-135)
			0.0: rotation = deg2rad(-90)
			1.0: rotation = deg2rad(-45)
		0.0: match round(direction.y):
			-1.0: rotation = deg2rad(180)
			0.0: rotate(0)
			1.0: rotation = 0
		-1.0: match round(direction.y):
			-1.0: rotation = deg2rad(135)
			0.0: rotation = deg2rad(90)
			1.0: rotation = deg2rad(45)

# Make the guard alert
func make_alert(location: Vector2, path: PoolVector2Array):
	state = State.ALERT
	to_investigate = location
	investigate_index = 0
	investigate_route = path
	# Remove the las one, because that is the object that made the sound. The guard cannot move there.
	if investigate_route.size() > 0: investigate_route.remove(investigate_route.size() - 1)

func _draw():
	# TODO delete after testing
	# For debugging, making the guard's vision visible
	var from = Vector2(0, 0)
	var direction = seeing_direction * seeing_distance * Global.tile_size
	draw_line(from, direction + from, Color.yellow, 1)
	draw_line(from, direction.rotated(deg2rad(seeing_angle / 2.0)) + from, Color.yellow, 1)
	draw_line(from, direction.rotated(-deg2rad(seeing_angle / 2.0)) + from, Color.yellow, 1)

func _on_InteractiveArea_body_entered(body):
	if body is NoiseMaker:
		# Disable the alarm that attracted the guard
		body.disable()
