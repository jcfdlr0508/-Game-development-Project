extends Node

var current_checkpoint : Checkpoint
var player : Player
var lives = 3

func respawn_player():
	if current_checkpoint and not current_checkpoint.is_queued_for_deletion():
		player.position = current_checkpoint.spawn_point
	else:
		player.position = player.respawn_point

func reset_checkpoint():
	current_checkpoint = null

func _ready():
	# Assuming player is already assigned or you can get it from the scene
	player = $Player  # Adjust the path as necessary

func change_scene(new_scene_path):
	# Reset the current checkpoint to avoid accessing it after it's freed
	reset_checkpoint()
	# Change scene
	get_tree().change_scene(new_scene_path)

	# Save the player's lives across scenes
	$GlobalScope.lives = lives
