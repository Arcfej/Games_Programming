extends StaticBody2D
class_name NoiseMaker

# Location is in global coordinates, distance is in number of tiles forizontally or vertically
signal noise(location, distance)

# Indicate if the alarm is flashing red at the moment
var is_red = false

# How loud is the noise (how far can it be heard)
export(int) var hearing_distance = 10

func _process(delta):
	# Color the sprite according to is_red
	$Sprite.self_modulate = Color.red if is_red else Color.white

# Called when the player makes a noise
func interact_with():
	emit_signal("noise", global_position, hearing_distance)
	is_red = true
	# Start a timer which will blink the alarm red and yellow
	$Timer.start()

# Disable the blinking
func disable():
	$Timer.stop()
	is_red = false

# Change the alarm's color perodically if the timer runs
func _on_Timer_timeout():
	is_red = !is_red
