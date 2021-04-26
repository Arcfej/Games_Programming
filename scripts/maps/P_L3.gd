extends Map

func _ready():
	# Set the patroling steps for the guard
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.STAND, 200, null))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.CHANGE_DIRECTION, 0, Vector2(-1, 0)))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.STAND, 1000, null))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.MOVE, 0, Vector2(1, 5)))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.STAND, 200, null))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.CHANGE_DIRECTION, 0, Vector2(1, 0)))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.STAND, 1000, null))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.MOVE, 0, Vector2(9, 5)))
