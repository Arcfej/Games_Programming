extends Area2D
class_name Entrance

var id setget set_id, get_id

func _on_Entrance_area_entered(area):
	Global.entrance_reached(id)

func set_id(ID):
	id = ID

func get_id():
	return id
