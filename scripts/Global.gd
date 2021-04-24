# Global class for storing a lot of information
extends Node

# LAYERS:
# Layer 1:	for physical collisions and area detections
# Layer 20:	for interacting with Nodes in the world

# The currently visible map
var current_map
# The entrance the player used last
export var last_entrance = 5
# The tile size of the maps
export var tile_size = 16
# The scale applied to the maps
export(Vector2) var map_scale = Vector2(3, 3)

# Entrances on the map. 
# Each entrances identified by an id.
# id = { <nested entrance dictionary>
# 	map:				the path to the destination map
# 	destination: 		the arriving position on destination map
#	is_2way:			true, if travelling back is possible
#}
# When the player uses an entrance, it will arrive at that position on the map.
var entrances = {
	0 : {
		map = "res://nodes/maps/P_L1.tscn",
		destination = Vector2(0, 0),
	},
	1 : {
		map = "res://nodes/maps/P_L2.tscn",
		destination = Vector2(0, 5),
	},
	2 : {
		map = "res://nodes/maps/P_L1.tscn",
		destination = Vector2(3, 1),
	},
	3: {
		map = "res://nodes/maps/P_L3.tscn",
		destination = Vector2(5, 10),
	},
	4: {
		map = "res://nodes/maps/P_L2.tscn",
		destination = Vector2(1, 0),
	},
	5: {
		map = "res://nodes/maps/P_L4.tscn",
		destination = Vector2(8, 8),
	},
	6: {
		map = "res://nodes/maps/P_L3.tscn",
		destination = Vector2(5, 0),
	},
	7: {
		map = "res://nodes/maps/P_L5.tscn",
		destination = Vector2(0, 0),
	}
}

# Disconnectible object types. When they're connected, the player can go through them.
enum Disconnectible {Door}

# Disconnectibles on the map:
# id = { <nested dictionary>
#	type:				the type of the disconnectible, see enum above
#	is_connected:		if false, it counts as an obstacle between two paths
#}
var disconnectibles = {
	1: {
		type = Disconnectible.Door,
		is_connected = true
	},
	2: {
		type = Disconnectible.Door,
		is_connected = true
	},
	3: {
		type = Disconnectible.Door,
		is_connected = false
	},
	4: {
		type = Disconnectible.Door,
		is_connected = true
	},
	5: {
		type = Disconnectible.Door,
		is_connected = false
	},
	6: {
		type = Disconnectible.Door,
		is_connected = false
	},
	7: {
		type = Disconnectible.Door,
		is_connected = true
	},
	8: {
		type = Disconnectible.Door,
		is_connected = false
	},
	9: {
		type = Disconnectible.Door,
		is_connected = false
	},
	10: {
		type = Disconnectible.Door,
		is_connected = false
	},
	11: {
		type = Disconnectible.Door,
		is_connected = false
	},
	12: {
		type = Disconnectible.Door,
		is_connected = true
	},
	13: {
		type = Disconnectible.Door,
		is_connected = true
	},
	14: {
		type = Disconnectible.Door,
		is_connected = false
	},
	15: {
		type = Disconnectible.Door,
		is_connected = true
	}
}

# Loads a new map when the entrance is usedl
func entrance_reached(entrance_id : int):
	call_deferred("_deferred_change_map", entrance_id)

# Inner function for deferred loading of the new map.
# It should be called only with `call_deferred()`
# Inputs: the path of the map's file and the position to place the player on after loading
func _deferred_change_map(entrance_id : int):
	# Remove the player from the old map if there's any
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	# Free up the current map if there's any
	if current_map:
		current_map.free()
	
	# TODO optimize loading
	current_map = load(entrances[entrance_id]["map"]).instance()
	if current_map:
		# Save the last used entrance
		last_entrance = entrances[entrance_id]
		# Add the new map to Main/MapLayer then place the player on it
		get_tree().get_root().get_node("/root/Main").add_child(current_map)
		current_map.place_player(last_entrance["destination"])
