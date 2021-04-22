extends Map

func _ready():
	# Set the patroling route for the guard
	$Foreground/Guard.route.append(Movement.new(Movement.Type.STAND, 200, null))
	$Foreground/Guard.route.append(Movement.new(Movement.Type.CHANGE_DIRECTION, 0, Vector2(-1, 0)))
	$Foreground/Guard.route.append(Movement.new(Movement.Type.STAND, 1000, null))
	$Foreground/Guard.route.append(Movement.new(Movement.Type.MOVE, 0, Vector2(1, 5)))
	$Foreground/Guard.route.append(Movement.new(Movement.Type.STAND, 200, null))
	$Foreground/Guard.route.append(Movement.new(Movement.Type.CHANGE_DIRECTION, 0, Vector2(1, 0)))
	$Foreground/Guard.route.append(Movement.new(Movement.Type.STAND, 1000, null))
	$Foreground/Guard.route.append(Movement.new(Movement.Type.MOVE, 0, Vector2(9, 5)))
