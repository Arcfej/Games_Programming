extends Map

func _ready():
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.MOVE, 0, Vector2(12, 4)))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.CHANGE_DIRECTION, 0, Vector2(0, 1)))
