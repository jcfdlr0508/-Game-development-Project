extends Area2D
class_name Checkpoint

@export var spawn_point = Vector2.ZERO
var activated = false
var player : Player
var hp = 100

func activate():
	if not activated:
		print("Checkpoint Activated")
		spawn_point = position
		GameManager.current_checkpoint = self
		activated = true
		if player:
			player.hp = hp
			player.player_health_bar.value = hp
			GameManager.player.respawn_point = self.position
			GameManager.player.hp = 100 
		$AnimatedSprite2D.play("idle")

func _on_area_entered(area):
	if area.is_in_group("Player") and not activated:
		activate()

func _on_body_entered(body):
	if body.is_in_group("Player") and not activated:
		activate()
	if body.get_name() == "Player":
		var health_to_add = 100 - body.hp  # Calculate the exact amount needed to reach 100
		body.increase_health(health_to_add)  # Increase health by the calculated amount
		body.increase_lives(1)
