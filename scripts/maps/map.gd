extends Node2D
class_name Map

# Places where you can leave the map
var exits = {} setget , get_exits

func _ready():
	# If you inherit this class, set the exits and every Entrance nodes' id here
	pass

func _process(delta):
	_set_player_movement_boundaries()

func get_exits():
	return exits

# Place the player character on the map, usally after the map has loaded
# Do not use this to move the player on the map
func place_player(position, is_2way_travel):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	add_child(PPlayer, true)
	PPlayer.enter_map(position * Global.tile_size, is_2way_travel)

# Updates the boundaries the player can move in, based on its position on thsi map
func _set_player_movement_boundaries():
	var boundaries = Rect2(PPlayer.position, Vector2(0, 0))
	var up_allowed = true
	var right_allowed = true
	var left_allowed = true
	var down_allowed = true
	
	# Go through all the tile-map layers
	for child in get_children():
		if child is TileMap:
			# Check if movement is allowed in the 4 directions.
			# Calculations use the Player's collision shape.
			# It has to remain on tiles where the player's allowed
			# Up
			if !_is_destination_allowed(child, Vector2(PPlayer.position.x + (Global.tile_size - PPlayer.get_collision_shape().get_radius() * 2 - PPlayer.get_collision_shape().get_height()) / 2, PPlayer.position.y - PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(0, -1)):
				up_allowed = false
			# Right
			if !_is_destination_allowed(child, Vector2(PPlayer.position.x + Global.tile_size / 2 + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_shape().get_height() / 2, PPlayer.position.y + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(1, 0)):
				right_allowed = false
			# Down
			if !_is_destination_allowed(child, Vector2(PPlayer.position.x + Global.tile_size / 2 + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_shape().get_height() / 2, PPlayer.position.y + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(0, 1)):
				down_allowed = false
			# Left
			if !_is_destination_allowed(child, Vector2(PPlayer.position.x + (Global.tile_size - PPlayer.get_collision_shape().get_radius() * 2 - PPlayer.get_collision_shape().get_height()) / 2, PPlayer.position.y - PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(-1, 0)):
				left_allowed = false
	# Modify the movement boundary (initially nothing's allowed)
	# Boundary is a rectangle that's size is 1, 2 or 3 times the tile-size
	if left_allowed:
		boundaries.position.x -= Global.tile_size
		boundaries.end.x += Global.tile_size
	if up_allowed:
		boundaries.position.y -= Global.tile_size
		boundaries.end.y += Global.tile_size
	if right_allowed:
		boundaries.end.x += Global.tile_size
	if down_allowed:
		boundaries.end.y += Global.tile_size
	# Set the boundary on the player
	PPlayer.set_movement_boundaries(boundaries)

# Checks if the given position on the tile-map layer is allowed to move onto
func _is_destination_allowed(tile_map, position):
	var allowed = false
	
	var tile_id = tile_map.get_cellv(tile_map.world_to_map(position))
	# If the given cell is empty, the movement is allowed
	if tile_id == TileMap.INVALID_CELL: return true
	
	var tile_name = tile_map.tile_set.tile_get_name(tile_id)
	# Open doors and paths are allowed
	if tile_name.begins_with("path") or tile_name == "door_opened":
		allowed = true
	# Else let's allowed to false
	
	return allowed
