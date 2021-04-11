extends Node

var current_map

func _ready():
	change_map("res://nodes/maps/P_L1.tscn", Vector2(1, 1))

func change_map(path, player_position):
	call_deferred("_deferred_change_map", path, player_position)

func _deferred_change_map(path, player_position):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	if current_map:
		current_map.free()
	
	# TODO optimize loading
	current_map = load(path).instance()
	get_tree().get_root().get_node("/root/Main/MapLayer").add_child(current_map)
	get_tree().set_current_scene(current_map)
	current_map.add_child(PPlayer)
	
	current_map.set_player_position(player_position)
