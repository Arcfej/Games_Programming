extends Map

func _ready():
	$Foreground/Guard.route.append(Movement.new(Movement.Type.MOVE, 0, Vector2(11, 0)))
