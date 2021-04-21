extends KinematicBody2D

# Seeing distance in tiles
export(int) var seeing_distance
export(int, EXP, 0, 90) var seeing_angle
export(Vector2) var seeing_direction

func _ready():
	$RayCast2D.add_exception(self)

func _physics_process(delta):
	# Check if guard can see player
	var enemy_to_player = PPlayer.position - position
	# If the player in seeing distance check further
	# + 1 to match to the visible distance measured by tiles
	if enemy_to_player.length() <= (seeing_distance + 1) * Global.tile_size:
		# TODO delete update() after testing
		update()
		# Check if the player is in the guard's angle of vision
		if abs(rad2deg(enemy_to_player.angle_to(seeing_direction.normalized()))) < seeing_angle / 2:
			# TODO improve raycasting by casting it as a tangent vector instead of to the middle
			$RayCast2D.cast_to = enemy_to_player
			# Ray-cast to the player and check if nothing's obscure the guard's view
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider().get_parent() == PPlayer:
				print("Enemy sees you!")
			else: print("You're invisible")

func _draw():
	# For debugging, making the guard's vision visible
	var from = Vector2(Global.tile_size / 2, Global.tile_size / 2)
	draw_line(from, seeing_direction * (seeing_distance + 1) * Global.tile_size + from, Color.yellow, 1.1)
	draw_line(from, seeing_direction.rotated(deg2rad(seeing_angle / 2)) * (seeing_distance + 1) * Global.tile_size + from, Color.yellow, 1.1)
	draw_line(from, seeing_direction.rotated(-deg2rad(seeing_angle / 2)) * (seeing_distance + 1) * Global.tile_size + from, Color.yellow, 1.1)
	draw_line(from, to_local(PPlayer.global_position) + from, Color.red, 1.5)
