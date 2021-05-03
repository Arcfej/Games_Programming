extends CenterContainer

func _input(event):
	if event.is_action_pressed("ui_accept"):
		Global.entrance_reached(0)
