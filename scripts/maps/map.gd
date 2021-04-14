extends Node2D
class_name Map

var entrances = [] setget , get_entrances
#var player_position = Vector2(0, 0) setget set_player_position, get_player_position # Vector2

func _ready():
	#PPlayer.position = player_position
	pass

func _process(delta):
	_set_player_movement_boundaries()

func get_entrances():
	return entrances

#func set_player_position(position):
#	player_position = position

#func get_player_position():
#	return player_position

func get_tile_by_position(position):
	print(position)

func place_player(position):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	add_child(PPlayer, true)
	PPlayer.position = position * Global.tile_size

func _set_player_movement_boundaries():
	var boundaries = Rect2(PPlayer.position, Vector2(0, 0))
	var up_allowed = true
	var right_allowed = true
	var left_allowed = true
	var down_allowed = true
	# TODO fix up and left -1px movement boundary
	for child in get_children():
		if child is TileMap:
			# Up
			if !_check_movement_at_position(child, Vector2(PPlayer.position.x + (Global.tile_size - PPlayer.get_collision_shape().get_radius() * 2 - PPlayer.get_collision_shape().get_height()) / 2, PPlayer.position.y - PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(0, -1)):
				up_allowed = false
			# Right
			if !_check_movement_at_position(child, Vector2(PPlayer.position.x + Global.tile_size / 2 + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_shape().get_height() / 2, PPlayer.position.y + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(1, 0)):
				right_allowed = false
			# Down
			if !_check_movement_at_position(child, Vector2(PPlayer.position.x + Global.tile_size / 2 + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_shape().get_height() / 2, PPlayer.position.y + PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(0, 1)):
				down_allowed = false
			# Left
			if !_check_movement_at_position(child, Vector2(PPlayer.position.x + (Global.tile_size - PPlayer.get_collision_shape().get_radius() * 2 - PPlayer.get_collision_shape().get_height()) / 2, PPlayer.position.y - PPlayer.get_collision_shape().get_radius() + PPlayer.get_collision_object().position.y) + Vector2(-1, 0)):
				left_allowed = false
				
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
	
	PPlayer.set_movement_boundaries(boundaries)

func _check_movement_at_position(tile_map, position):
	var allowed = false
	var tile_id = tile_map.get_cellv(tile_map.world_to_map(position))
	if tile_id == TileMap.INVALID_CELL: return true
	var tile_name = tile_map.tile_set.tile_get_name(tile_id)
	if tile_name.begins_with("path") or tile_name == "door_opened":
		allowed = true
	elif tile_name == "door_closed":
		allowed = false
	return allowed
