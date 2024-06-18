extends Control



func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Main-Character.tscn")

func _on_about_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
