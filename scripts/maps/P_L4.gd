extends Map

func _ready():
	$Foreground/Guard.patrol_route.append(Movement.new(Movement.Type.MOVE, 0, Vector2(11, 0)))
	$Foreground/Guard.patrol_route.append(Movement.new(Movement.Type.CHANGE_DIRECTION, 0, Vector2(0, -1)))
