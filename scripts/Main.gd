extends Node

func _ready():
	# TODO fix bug, where after entering a new location, the player can move outside the map
	Global.entrance_reached(Global.last_entrance) # Start the game at the beginning
