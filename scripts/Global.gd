# Global class for storing a lot of information
extends Node

# Layer 20: interactive

# The currently visible map
var current_map
# The tile size of the maps
export var tile_size = 16

# Entrances on the map. 
# Each entrances identified by an id.
# id = {nested entrance dictionary}
# 	map:				the path to the destination map
# 	destination: 		the arriving position on destination map
#	is_2way:			true, if travelling back is possible
# When the player uses an entrance, it will arrive at that position on the map.
export var entrances = {
	0 : {
		map = "res://nodes/maps/P_L1.tscn",
		destination = Vector2(0, 0),
		is_2way = false
	},
	1 : {
		map = "res://nodes/maps/P_L2.tscn",
		destination = Vector2(0, 5),
		is_2way = true
	},
	2 : {
		map = "res://nodes/maps/P_L1.tscn",
		destination = Vector2(3, 1),
		is_2way = true
	},
	3: {
		map = "res://nodes/maps/P_L3.tscn",
		destination = Vector2(0, 0),
		is_2way = true
	}
}

# Loads a new map when the entrance is usedl
func entrance_reached(entrance_id):
	call_deferred(
		"_deferred_change_map",
		entrances[entrance_id]["map"],
		entrances[entrance_id]["destination"],
		entrances[entrance_id]["is_2way"])

# Inner function for deferred loading of the new map.
# It should be called only with `call_deferred()`
# Inputs: the path of the map's file and the position to place the player on after loading
func _deferred_change_map(path, player_position, is_2way_travel):
	# Remove the player from the old map if there's any
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	# Free up the current map if there's any
	if current_map:
		current_map.free()
	
	# TODO optimize loading
	current_map = load(path).instance()
	# Add the new map to Main/MapLayer then place the player on it
	get_tree().get_root().get_node("/root/Main").add_child(current_map)
	current_map.place_player(player_position, is_2way_travel)
