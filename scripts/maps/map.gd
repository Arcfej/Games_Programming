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
				# Enable or disable the navigation point at the door
				var door_id = Global.calc_point_id(door.position.x, door.position.y, Global.map_area.size.x)
				if Global.nav_map.has_point(door_id):
					Global.nav_map.set_point_disabled(door_id, not door.is_open)
					# TODO delete after testing
					update()

# When a noise is made, alert all the guards in hearing distance
# Location is in global coordinates, distance is in number of tiles horizontally or vertically
func _on_NoiseMaker_noise(location: Vector2, distance: int):
	print("Noise made")
	for listener in get_tree().get_nodes_in_group("listener"):
		if listener is Guard and (to_local(location) - listener.position).length_squared() < pow(distance * Global.tile_size, 2):
			var path = Global.find_path(listener.global_position, location, true)
			listener.make_alert(location, path)

func _draw():
	# TODO delete after testing
	for point_id in Global.nav_map.get_points():
		if Global.nav_map.is_point_disabled(point_id): continue
		var position = to_global($Foreground.map_to_world(Global.nav_map.get_point_position(point_id))) / 3
		draw_circle(position, 1, Color.pink)
