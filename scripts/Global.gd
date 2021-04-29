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
		map = "res://nodes/maps/P_L6.tscn",
		destination = Vector2(4, 6),
	},
	10: {
		id = 10,
		map = "res://nodes/maps/P_L5.tscn",
		destination = Vector2(8, 0),
	},
	11: {
		id = 11,
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
	},
	24: {
		type = Disconnectible.Door,
		is_connected = true
	},
	25: {
		type = Disconnectible.Door,
		is_connected = true
	},
	26: {
		type = Disconnectible.Door,
		is_connected = false
	},
	27: {
		type = Disconnectible.Door,
		is_connected = false
	},
	28: {
		type = Disconnectible.Door,
		is_connected = true
	}
}

func _ready():
	last_entrance = entrances[0]

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
		# Connect to disconnectible state changes on the new map
		for door in get_tree().get_nodes_in_group("doors"):
			door.connect("door_state_changed", self, "_on_door_state_changed")

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
	for door in get_tree().get_nodes_in_group("doors"):
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

# Find a path between two points without interacting with objects on the map.
# The TileMaps on the current map have to have the same offset
#	is_global:		If false, it means the coordinates are TileMap coordinates
func find_simple_path(from: Vector2, to: Vector2, is_global: bool) -> PoolVector2Array:
	# The first part of this method is repeated in find_interactive_path
	var map = _get_map_reference()
	# If there's not a TiledMap on current_map, return an empty array
	if not map: return PoolVector2Array([])
	
	# Convert to TileMap coordinates then return the calculated path
	if is_global:
		from = map.world_to_map(map.to_local(from))
		to = map.world_to_map(map.to_local(to))
	
	return _find_simple_path(from, to)

# Find the shortest path between two points, including actions when you interact with objects on the way
# The TileMaps on the current map have to have the same offset
#	key_ids:		the id of the doors the character can open with their key(s)
#	is_global:		If false, it means the coordinates are TileMap coordinates
func find_interactive_path(from: Vector2, to: Vector2, key_ids: PoolIntArray,
		is_global: bool) -> PoolVector2Array:
	# The first part of this method is repeated in find_simple_path
	var map = _get_map_reference()
	# If there's not a TiledMap on current_map, return an empty array
	if not map: return PoolVector2Array([])
	
	# Convert to TileMap coordinates then return the calculated path
	if is_global:
		from = map.world_to_map(map.to_local(from))
		to = map.world_to_map(map.to_local(to))
	
	# Initial solution is the simple path withouth interacting with objects
	var solution = _find_simple_path(from, to)
	var interactives = get_tree().get_nodes_in_group("interactives")
	
	# Find the solution which takes the least steps
	solution = _recursive_find(from, to, interactives, key_ids, PoolVector2Array([]), solution, UndoRedo.new())
	
	return solution

# Internal function to find a simple path between two points without interacting
# with objects on the way. Coordinates are TileMap coordinates
func _find_simple_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	return nav_map.get_point_path(
		calc_point_id(from.x, from.y, map_area.size.x),
		calc_point_id(to.x, to.y, map_area.size.x))

# Internal function to calculate the shortest interactive path recursively.
#	from, to:		coordinates are in TiledMap coordinates
#	interactives:	the objects the character can interact with on the map
#	key_ids:		the doors the character can open with their key(s)
#	path_done:		the path the character have done so far (in the previous _recursive_find method)
#	solution:		the shortest path found so far
#	unde_redo:		to do/undo actions on the objects and nav_map while searching for a path
func _recursive_find(from: Vector2, to: Vector2, interactives: Array,
		key_ids: PoolIntArray, path_done: PoolVector2Array, solution: PoolVector2Array,
		undo_redo: UndoRedo) -> PoolVector2Array:
	# Go through all the interactives
	for interactive in interactives:
		# For counting how many actions have to be undone after every iteration
		# to restore the nav_map and interactive to their initial state
		var undo_count = 0
		# Ignore the NoiseMakers
		if interactive is NoiseMaker: continue
		# Ignore open doors as the character can already move across them
		if interactive is Door and interactive.is_open: continue
		# Ignore closed doors the character cannot open
		if interactive is Door:
			var has_key
			for key in key_ids:
				has_key = key == interactive.id
				if has_key: break
			if not has_key: continue
		
		# Convert the interactive's position to TileMap coordinates
		var object_position = global_to_tile_map(interactive.global_position)
		# Ignore the interactives that just has been reached
		if object_position == from: continue
		# Initialize a new path to operate on from path_done
		var path = path_done
		
		# Enable the interactive on the nav_map temporarily to be able to navigate there
		undo_redo.create_action("Nav-point enabled")
		undo_redo.add_do_method(nav_map, "set_point_disabled", calc_point_id(object_position.x, object_position.y, map_area.size.x), false)
		undo_redo.add_undo_method(nav_map, "set_point_disabled", calc_point_id(object_position.x, object_position.y, map_area.size.x), true)
		while[true]:
			if not undo_redo.is_commiting_action(): break
		undo_redo.commit_action()
		undo_count += 1
		
		# Calculate the path to the interactive
		path.append_array(_find_simple_path(from, object_position))
		# Disable the interactive again on the nav_map if no path found or the path is longer then a valid solution
		# Iterate to the next interactive
		if path.size() == path_done.size() or (solution.size() > 0 and path.size() > solution.size()):
			undo_redo.undo()
			continue
		
		# If the interactive is a door, open it temporarily
		if interactive is Door:
			undo_redo.create_action("open_door")
			undo_redo.add_do_method(interactive, "set_state", true)
			undo_redo.add_undo_method(interactive, "set_state", false)
			undo_redo.add_do_method(self, "_on_door_state_changed", interactive.id, true)
			undo_redo.add_undo_method(self, "_on_door_state_changed", interactive.id, false)
			while[true]:
				if not undo_redo.is_commiting_action(): break
			undo_redo.commit_action()
			undo_count += 1
		# If the interactive is a switch, switch it once
		elif interactive is Switch:
			for id in interactive.connected_door_ids:
				for door in get_tree().get_nodes_in_group("doors"):
					if door.id == id:
						# Change every connected door's state temporarily
						var was_open = door.is_open
						undo_redo.create_action("switch")
						undo_redo.add_do_method(door, "set_state", false if was_open else true)
						undo_redo.add_undo_method(door, "set_state", true if was_open else false)
						undo_redo.add_do_method(self, "_on_door_state_changed", id, false if was_open else true)
						undo_redo.add_undo_method(self, "_on_door_state_changed", id, true if was_open else false)
						while[true]:
							if not undo_redo.is_commiting_action(): break
						undo_redo.commit_action()
						undo_count += 1
		
		# Remove the last step before calculating further paths
		# (The last step will be the first step of the calculated further path. This way the step won't be duplicated)
		var last_point = from
		if path.size() > 0:
			last_point = path[path.size() - 1]
			path.remove(path.size() - 1)
		# Check if the goal is reachable after interacting with the interactive
		var path_to_end = path
		path_to_end.append_array(_find_simple_path(last_point, to))
		# If a way is found to the goal and it's shorter than a valid solution (longer than 0), overwrite solution with this path
		if path_to_end.size() > path.size() and (path_to_end.size() < solution.size() or solution.size() == 0):
			solution = path_to_end
		# After 50 steps, deem the goal unreachable
		# Before 50 steps have been taken, check if the taken path so far is still shorter than solution
		if path.size() < 50 and (solution.size() == 0 or path.size() < solution.size()):
			# Find further paths recursively and append it
			path.append_array(_recursive_find(last_point, to, interactives, key_ids, path, solution, undo_redo))
			# If the new path ends with the goal and it's shorter then solution, replace solution with it
			if path.size() > 0 and path[path.size() - 1] == to and path.size() < solution.size():
				solution = path
		# Restore the state of nav_map and the interactive before going to the next iteration
		for _i in range(undo_count):
			while[true]:
				if not undo_redo.is_commiting_action(): break
			undo_redo.undo()
	return solution

# Called when a state of a door is changed.
# Register the change on nav_map
func _on_door_state_changed(id: int, is_open: bool):
	# TODO send nav_map_changed signals for path-following guards
	var map = _get_map_reference()
	# If there's not a TiledMap on current_map, return
	if not map: return
	
	for door in get_tree().get_nodes_in_group("doors"):
		# Find the correct door
		if door.id != id: continue
		# Save it's changed state both in data and navigation
		disconnectibles[id]["is_connected"] = is_open
		var map_coordinate = map.world_to_map(door.position)
		nav_map.set_point_disabled(
			calc_point_id(map_coordinate.x, map_coordinate.y, map_area.size.x),
			not is_open)

# Return a TiledMap if there is one on current_map for coordinate conversion purposes.
# Return null, if there's no TiledMap on current map
func _get_map_reference() -> TileMap:
	# Find first TileMap child
	var map: TileMap
	for child in current_map.get_children():
		if child is TileMap:
			return child
	return null

# Convert local coordinates to TileMap coordinates (local by TileMap)
func local_to_tile_map(from: Vector2) -> Vector2:
	# Find first TileMap child
	var map: TileMap = _get_map_reference()
	return map.world_to_map(from)

# Convert gloval coordinates to TileMap coordinates
func global_to_tile_map(from: Vector2) -> Vector2:
	var map: TileMap = _get_map_reference()
	return map.world_to_map(map.to_local(from))

# Convert TileMap coordinates to local ones (local by TileMap)
func tile_map_to_local(from: Vector2) -> Vector2:
	# Find first TileMap child
	var map: TileMap = _get_map_reference()
	return map.map_to_world(from)
