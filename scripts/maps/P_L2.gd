extends Map

func _ready():
	.get_entrances()[2] = Global.entrances[2]["destination"]
	$Entrance_2.set_id(2)
	.get_entrances()[3] = Global.entrances[3]["destination"]
	$Entrance_3.set_id(3)
