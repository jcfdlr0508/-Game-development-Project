extends Area2D

var item = "health_potion"

func _on_body_entered(body: Node2D):
	if body is Main_Character:
		body.add_points(10) # Add 10 points to the player's score
		queue_free()
