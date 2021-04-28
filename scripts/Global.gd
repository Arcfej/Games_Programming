# Global class for storing a lot of information
extends Node

# LAYERS:
# Layer 1:	for physical collisions and area detections
# Layer 10:	for seeing and be noticable by enemies and everything which blocking view
# Layer 20:	for interacting with Nodes in the world

# The currently visible map
var current_map
# The entrance the player used last
export(Dictionary) var last_entrance
# The tile size of the maps
export(int) var tile_size = 16
# The scale applied to the maps
export(Vector2) var map_scale = Vector2(3, 3)

# The navigation map for AI movements
var nav_map : AStar2D
# The area which encapsulate all the tiles on all the TileMaps (layers).
# Only calculated if need_navigation is true
var map_area: Rect2

# Entrances on the map. 
# Each entrances identified by an id.
# id = { <nested entrance dictionary>
# 	map:				the path to the destination map
# 	destination: 		the arriving position on destination map
#	is_2way:			true, if travelling back is possible
#}
# When the player uses an entrance, it will arrive at that position on the map.
var entrances = {
	-1: {
		id = -1,
		map = "res://nodes/maps/PlayerSeen.tscn",
	},
	0 : {
		id = 0,
		map = "res://nodes/maps/P_L1.tscn",
		destination = Vector2(0, 0),
	},
	1 : {
		id = 1,
		map = "res://nodes/maps/P_L2.tscn",
		destination = Vector2(0, 5),
	},
	2 : {
		id = 2,
		map = "res://nodes/maps/P_L1.tscn",
		destination = Vector2(3, 1),
	},
	3: {
		id = 3,
		map = "res://nodes/maps/P_L3.tscn",
		destination = Vector2(5, 10),
	},
	4: {
		id = 4,
		map = "res://nodes/maps/P_L2.tscn",
		destination = Vector2(1, 0),
	},
	5: {
		id = 5,
		map = "res://nodes/maps/P_L4.tscn",
		destination = Vector2(8, 8),
	},
	6: {
		id = 6,
		map = "res://nodes/maps/P_L3.tscn",
		destination = Vector2(5, 0),
	},
	7: {
		id = 7,
		map = "res://nodes/maps/P_L5.tscn",
		destination = Vector2(8, 9),
	},
	8: {
		id = 8,
		map = "res://nodes/maps/P_L4.tscn",
		destination = Vector2(11, 0),
	},
	9: {
		id = 9,
		map = "res://nodes/maps/WinScreen.tscn",
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
	},
	16: {
		type = Disconnectible.Door,
		is_connected = true
	},
	17: {
		type = Disconnectible.Door,
		is_connected = true
	},
	18: {
		type = Disconnectible.Door,
		is_connected = true
	},
	19: {
		type = Disconnectible.Door,
		is_connected = true
	},
	20: {
		type = Disconnectible.Door,
		is_connected = false
	},
	21: {
		type = Disconnectible.Door,
		is_connected = true
	},
	22: {
		type = Disconnectible.Door,
		is_connected = false
	},
	23: {
		type = Disconnectible.Door,
		is_connected = false
	}
}

func _ready():
	last_entrance = entrances[5]

# Call it when the player has been seen by a guard. It will display a loosing screen
func player_seen():
	call_deferred("_deferred_change_map" , -1, false)

# Loads a new map when the entrance is usedl
func entrance_reached(entrance_id : int):
	call_deferred("_deferred_change_map", entrance_id, true)

# Inner function for deferred loading of the new map.
# It should be called only with `call_deferred()`
# Inputs: the path of the map's file, tand if the player needs to be placed on the map
func _deferred_change_map(entrance_id: int, needs_player: bool):
	# Remove the player from the old map if they's need to place on the new one
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	# Free up the current map if there's any
	if current_map:
		current_map.free()
	
	# TODO optimize loading
	current_map = load(entrances[entrance_id]["map"]).instance()
	if current_map:
		# Save the last used entrance if it was a map
		if entrance_id >= 0:
			last_entrance = entrances[entrance_id]
		# Add the new map to Main/MapLayer
		get_tree().get_root().get_node("/root/Main").add_child(current_map)
		# Initialize a new navigation map
		init_navigation()
		if needs_player and last_entrance.has("destination"):
			# Place the player on the map
			if current_map.has_method("place_player"):
				current_map.place_player(last_entrance["destination"])

# Initializes a navigation graph for the map
func init_navigation():
	nav_map = AStar2D.new()
	
	# Collect all the TiledMaps
	var children = current_map.get_children()
	var maps = []
	for child in children:
		if child is TileMap:
			maps.append(child)
	
	# Get the area which encloses all the tilemaps
	# (searching for max and min values for top-left and bottom-right corners)
	for map in maps:
		var layer_area = map.get_used_rect()
		if layer_area.position.x < map_area.position.x:
			map_area.position.x = layer_area.position.x
		if layer_area.position.y < map_area.position.y:
			map_area.position.y = layer_area.position.y
		if layer_area.end.x > map_area.end.x:
			map_area.end.x = layer_area.end.x
		if layer_area.end.y > map_area.end.y:
			map_area.end.y = layer_area.end.y
	
	# Collect all the nodes from the tilemaps
	# TODO what to do with layers that has offset?
	for y in range(map_area.size.y):
		for x in range(map_area.size.x):
			for map in maps:
				var cell_id = map.get_cell(x, y)
				# If the cell's name starts with 'path', it is a node
				if cell_id != TileMap.INVALID_CELL and map.tile_set.tile_get_name(cell_id).begins_with("path"):
					var point_id = calc_point_id(x, y, map_area.size.x)
					nav_map.add_point(point_id, Vector2(x, y))
	
	# Connect the nearby points together
	for point_id in nav_map.get_points():
		var point = nav_map.get_point_position(point_id)
		var neighbors = PoolVector2Array([
			Vector2(point.x, point.y - 1),
			Vector2(point.x, point.y + 1),
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y)
		])
		for neighbor in neighbors:
			var neighbor_id = calc_point_id(neighbor.x, neighbor.y, map_area.size.x)
			# If the neighboring tile is inside the area and part of the nav_map, connect
			if map_area.has_point(neighbor) and nav_map.has_point(neighbor_id):
				nav_map.connect_points(point_id, neighbor_id, true)
	
	# Disable points where doors are closed
	# TODO change this after new type of disconnectibles are introduced
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		# Skip if the door is open
		if door.is_open: continue
		var map_coordinate = maps[0].world_to_map(door.position)
		var door_id = calc_point_id(map_coordinate.x, map_coordinate.y, map_area.size.x)
		# If the door is on a walkable path
		if nav_map.has_point(door_id):
			nav_map.set_point_disabled(door_id, true)

# Calculates the id of a point for the navigation graph
# Using TileMap coordinates
func calc_point_id(x: int, y: int, area_width: int) -> int:
	return x + area_width * y

# Find a path between two points.
# The TileMaps on the current map have to have the same offset
#	is_global:		If false, it means the coordinates are TileMap coordinates
func find_path(from: Vector2, to: Vector2, is_global: bool) -> PoolVector2Array:
	# Find first TileMap child
	var map: TileMap
	for child in current_map.get_children():
		if child is TileMap:
			map = child
			break
	
	# Convert to TileMap coordinates then return the calculated path
	if is_global:
		from = map.world_to_map(map.to_local(from))
		to = map.world_to_map(map.to_local(to))
	return nav_map.get_point_path(
		calc_point_id(from.x, from.y, map_area.size.x),
		calc_point_id(to.x, to.y, map_area.size.x))

# Convert local coordinates to TileMap coordinates (local by TileMap)
func local_to_tile_map(from: Vector2) -> Vector2:
	# Find first TileMap child
	var map: TileMap
	for child in current_map.get_children():
		if child is TileMap:
			map = child
			break
	return map.world_to_map(from)

# Convert TileMap coordinates to local ones (local by TileMap)
func tile_map_to_local(from: Vector2) -> Vector2:
	# Find first TileMap child
	var map: TileMap
	for child in current_map.get_children():
		if child is TileMap:
			map = child
			break
	return map.map_to_world(from)
