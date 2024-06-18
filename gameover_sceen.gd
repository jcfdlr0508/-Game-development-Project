extends Control




func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
