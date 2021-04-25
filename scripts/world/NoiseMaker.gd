extends StaticBody2D
class_name NoiseMaker

# Location is in global coordinates, distance is in number of tiles forizontally or vertically
signal noise(location, distance)

export(int) var hearing_distance = 10

# Called when the player makes a noise
func interact_with():
	emit_signal("noise", global_position, hearing_distance)
