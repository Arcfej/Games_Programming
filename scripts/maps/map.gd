extends Node2D
class_name Map

var entrances = [] setget , get_entrances
var player_position = Vector2(0, 0) setget set_player_position, get_player_position # Vector2

func _ready():
	PPlayer.position = player_position

func place_player_on_map(position):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	add_child(PPlayer)
	player_position = position

func get_entrances():
	return entrances

func set_player_position(position):
	player_position = position

func get_player_position():
	return player_position
