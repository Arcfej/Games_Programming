extends Map

func _ready():
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.MOVE, 0, Vector2(13, 6)))
	$Foreground/Guard.patrol_steps.append(Movement.new(Movement.Type.CHANGE_DIRECTION, 0, Vector2(0, 1)))
	$Foreground/Guard.keys.append_array(PoolIntArray([23]))
