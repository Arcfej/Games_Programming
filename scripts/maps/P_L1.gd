extends Map

func _ready():
	.get_exits()[1] = Global.entrances[1]["destination"]
	$Entrance1.set_id(1)
