extends Node

var current_map

func _ready():
	change_map("res://nodes/maps/P_L1.tscn", Vector2(1, 1))

func change_map(path, player_position):
	call_deferred("_deferred_change_map", path, player_position)

func _deferred_change_map(path, player_position):
		# TODO optimize loading
	current_map = load(path).instance()
	get_tree().get_root().add_child(current_map)
	get_tree().set_current_scene(current_map)
	
	current_map.place_player_on_map(player_position)
