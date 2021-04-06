extends CanvasLayer

signal start_game

func show_message(text):
	$VBoxContainer/Message.text = text
	$VBoxContainer/Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	show_main_menu()

func show_main_menu():
	$VBoxContainer/Message.text = "Dodge the Guards"
	$VBoxContainer/Message.show()
	yield(get_tree().create_timer(1), "timeout")
	$"VBoxContainer/Start Button".show()

func update_score(score):
	print("Full score: " + String(score))
	var thousands = score / 1000
	score -= thousands * 1000
	print(String(thousands))
	var hundreds = score / 100
	score -= hundreds * 100
	print(String(hundreds))
	var tens = score / 10
	score -= tens * 10
	print(String(tens))
	print(String(score))
	$ScoreLabel.text = String(thousands) + String(hundreds) + String(tens) + String(score)


func _on_MessageTimer_timeout():
	$VBoxContainer/Message.hide()


func _on_Start_Button_pressed():
	$"VBoxContainer/Start Button".hide()
	emit_signal("start_game")
