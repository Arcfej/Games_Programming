extends Node2D
class_name Map

# True, if a navigation map is needed for the AI on this map
export(bool) var need_navigation = false
# The navigation map for AI movements
var nav_map : AStar2D
# The area which encapsulate all the tiles on all the TileMaps (layers).
# Only calculated if need_navigation is true
var map_area: Rect2

func _ready():
	# Set the scale for the map
	scale = Global.map_scale
	# Go through all the doors and load their saved state
	for door in get_tree().get_nodes_in_group("doors"):
		var is_open = Global.disconnectibles[door.get_id()]["is_connected"]
		door.set_state(is_open)
	# Create navigation map
	if need_navigation:
		_init_navigation()

# Initializes a navigation graph for the map
func _init_navigation():
	nav_map = AStar2D.new()
	
	# Collect all the TiledMaps
	var children = get_children()
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
					var point_id = _calc_point_id(x, y, map_area.size.x)
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
			var neighbor_id = _calc_point_id(neighbor.x, neighbor.y, map_area.size.x)
			# If the neighboring tile is inside the area and part of the nav_map, connect
			if map_area.has_point(neighbor) and nav_map.has_point(neighbor_id):
				nav_map.connect_points(point_id, neighbor_id, true)
	
	# Disable points where doors are closed
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		# Skip if the door is open
		if door.is_open: continue
		var map_coordinate = maps[0].world_to_map(door.position)
		var door_id = _calc_point_id(map_coordinate.x, map_coordinate.y, map_area.size.x)
		# If the door is on a walkable path
		if nav_map.has_point(door_id):
			nav_map.set_point_disabled(door_id, true)

# Calculates the id of a point for the navigation graph
func _calc_point_id(x: int, y: int, area_width: int) -> int:
	return x + area_width * y

# Find a path between two points. It's using local coordinates as parameters
func _find_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	# Find first TileMap child
	var map: TileMap
	for child in get_children():
		if child is TileMap:
			map = child
			break
	
	# Convert to TileMap coordinates then return the calculated path
	var start = map.world_to_map(from)
	var end = map.world_to_map(to)
	return nav_map.get_point_path(
		_calc_point_id(start.x, start.y, map_area.size.x),
		_calc_point_id(end.x, end.y, map_area.size.x))

# Place the player character on the map, usally after the map has loaded
# Do not use this to move the player on the map
func place_player(position: Vector2):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	add_child(PPlayer, true)
	PPlayer.enter_map(position * Global.tile_size)

# If a switch is switched, change the state of the connected doors
func _on_Switch_switch_doors(door_ids: Array):
	# TODO optimize nested for
	for id in door_ids:
		for door in get_tree().get_nodes_in_group("doors"):
			if id == door.get_id():
				door.switch()
				# If a navigation map has been initialized, enable or disable the point at the door
				if need_navigation:
					var door_id = _calc_point_id(door.position.x, door.position.y, map_area.size.x)
					nav_map.set_point_disabled(door_id, not door.is_open)
					# TODO delete after testing
					update()

# When a noise is made, alert all the guards in hearing distance
# Location is in global coordinates, distance is in number of tiles horizontally or vertically
func _on_NoiseMaker_noise(location: Vector2, distance: int):
	print("Noise made")
	for listener in get_tree().get_nodes_in_group("listener"):
		if listener is Guard and (to_local(location) - listener.position).length_squared() < pow(distance * Global.tile_size, 2):
			var path = _find_path(listener.position, to_local(location))
			listener.make_alert(location, path)

func _draw():
	# TODO delete after testing
	if not need_navigation: return
	for point_id in nav_map.get_points():
		if nav_map.is_point_disabled(point_id): continue
		var position = to_global($Foreground.map_to_world(nav_map.get_point_position(point_id))) / 3
		draw_circle(position, 1, Color.pink)
