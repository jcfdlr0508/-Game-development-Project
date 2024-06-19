extends Area2D

# This function is called when the node is added to the scene for the first time
func _ready():
	pass

# This function is called when a body enters the Area2D node
func _on_body_entered(body):
	if body.get_name() == "Player":  # Check if the body is the player
		body.reduce_health(100)  # Call the reduce_health function on the player
