extends Resource
class_name Movement

enum Type {STAND, MOVE, CHANGE_DIRECTION}

# The type of the movement, see the enum above
export(Type) var type
# Only applicable for STAND. Duration of it in millisecond
export(int) var duration
# Destination of the movement (in tile-map coordinates) or the vector for the changed direction
export(Vector2) var destination_or_direction

func _init(p_type = Type.STAND, p_duration = 0, p_destination_or_direction = Vector2(0, 0)):
	type = p_type
	duration = p_duration
	destination_or_direction = p_destination_or_direction
	resource_local_to_scene = true
