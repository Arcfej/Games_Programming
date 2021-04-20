extends Node2D
class_name Map

# Places where you can leave the map
var exits = {} setget , get_exits
var doors = {} setget , get_doors

func _ready():
	scale = Vector2(4, 4)

func get_exits():
	return exits

func get_doors():
	return doors

# Place the player character on the map, usally after the map has loaded
# Do not use this to move the player on the map
func place_player(position, is_2way_travel):
	if PPlayer.get_parent():
		PPlayer.get_parent().remove_child(PPlayer)
	add_child(PPlayer, true)
	PPlayer.enter_map(position * Global.tile_size, is_2way_travel)

# If a switch is switched, change the state of the connected doors
func _on_Switch_switch_doors(door_ids):
	# TODO optimize nested for
	for id in door_ids:
		for door in get_tree().get_nodes_in_group("doors"):
			if id == door.get_id():
				door.switch()
