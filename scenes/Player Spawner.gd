extends Node2D

var player_scene = preload("res://scenes/Main_Character.tscn")
var player = null

func _ready():
	spawn_player()

func _process(_delta):
	if player == null:
		spawn_player()

func spawn_player():
	var new_obj = player_scene.instantiate()
	new_obj.position = position
	get_parent().add_child(new_obj)
	player = new_obj
	player.connect("player_died", Callable(self, "_on_player_died"))

func _on_player_died():
	player = null  # Set player to null to respawn
	get_tree().create_timer(1.0).connect("timeout", Callable(self, "spawn_player"))  # Respawn after 1 second
