extends Node

func _ready():
	# TODO fix bug, where after entering a new location, the player can move outside the map
	Global.entrance_reached(0) # Start the game at the beginning
