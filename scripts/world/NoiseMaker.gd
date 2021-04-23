extends StaticBody2D
class_name NoiseMaker

signal noise(location, distance)

export(int) var hearing_distance = 10

# Called when the player makes a noise
func interact_with():
	emit_signal("noise", position, hearing_distance)
