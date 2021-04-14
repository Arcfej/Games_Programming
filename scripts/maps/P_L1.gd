extends Map

# Called when the node enters the scene tree for the first time.
func _ready():
	.get_entrances().append(Vector2(3, 1))
	$Entrance_1.set_id(1)
