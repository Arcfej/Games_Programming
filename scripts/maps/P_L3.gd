extends Map

func _ready():
	.get_exits()[4] = Global.entrances[4]["destination"]
	$Entrance4.set_id(4)
	.get_exits()[5] = Global.entrances[5]["destination"]
	$Entrance5.set_id(5)
