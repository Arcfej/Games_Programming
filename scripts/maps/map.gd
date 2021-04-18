extends Node2D
class_name Map

# Places where you can leave the map
var exits = {} setget , get_exits

func get_exits():
	return exits

# Place the player character on the map, usally after the map has loaded
# Do not use this to move the player on the map
func place_player(position, is_2way_travel):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	add_child(PPlayer, true)
	PPlayer.enter_map(position * Global.tile_size, is_2way_travel)
