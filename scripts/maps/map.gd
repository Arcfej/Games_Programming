extends Node2D
class_name Map

func _ready():
	# Set the scale for the map
	scale = Global.map_scale
	# Go through all the doors and load their saved state
	for door in get_tree().get_nodes_in_group("doors"):
		var is_open = Global.disconnectibles[door.get_id()]["is_connected"]
		door.set_state(is_open)

# Place the player character on the map, usally after the map has loaded
# Do not use this to move the player on the map
func place_player(position: Vector2, is_2way_travel: bool):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	add_child(PPlayer, true)
	PPlayer.enter_map(position * Global.tile_size, is_2way_travel)

# If a switch is switched, change the state of the connected doors
func _on_Switch_switch_doors(door_ids: Array):
	# TODO optimize nested for
	for id in door_ids:
		for door in get_tree().get_nodes_in_group("doors"):
			if id == door.get_id():
				door.switch()
