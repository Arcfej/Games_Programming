extends Node

export (PackedScene) var Guard
var score

func _ready():
	randomize()

func new_game():
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	
	$StartTimer.start()

func game_over():
	$ScoreTimer.stop()
	$GuardTimer.stop()
	$HUD.show_game_over()
	get_tree().call_group("guards", "queue_free")

func _on_StartTimer_timeout():
	$ScoreTimer.start()
	$GuardTimer.start()
	$Player.start($StartPosition.position)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_GuardTimer_timeout():
	# Get a random location on the path
	$SpawnPath/SpawnStartPoint.offset = randi()
	# Create a guard instance
	var guard = Guard.instance()
	add_child(guard)
	# Set the guard direction perpendicular to the path
	# (Pointing inward from the edge of the screen)
	var direction = round(rad2deg($SpawnPath/SpawnStartPoint.rotation + PI/2))
	# Set the position to the spawner's position
	guard.position = $SpawnPath/SpawnStartPoint.position
	# Set animation based on the direction
	match direction:
		0.0, -0.0:
			guard.get_node("AnimatedSprite").set_animation("right")
		90.0, -270.0:
			guard.get_node("AnimatedSprite").set_animation("down")
		180.0, -180.0:
			guard.get_node("AnimatedSprite").set_animation("left")
		270.0, -90.0:
			guard.get_node("AnimatedSprite").set_animation("up")
	# Set velocity based on direction
	guard.linear_velocity = Vector2(guard.speed, 0)
	guard.linear_velocity = guard.linear_velocity.rotated(deg2rad(direction))


func _on_HUD_start_game():
	new_game()
