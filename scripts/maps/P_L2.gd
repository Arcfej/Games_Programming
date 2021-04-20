extends Map

func _ready():
	.get_exits()[2] = Global.entrances[2]["destination"]
	$Entrance2.set_id(2)
	.get_exits()[3] = Global.entrances[3]["destination"]
	$Entrance3.set_id(3)
