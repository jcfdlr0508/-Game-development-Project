extends CharacterBody2D

@onready var sprite_2d = $AnimatedSprite2D

const speed = 150.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = false


func _physics_process(delta):
	#Idling Position
	if sprite_2d.animation == "Idle":
		sprite_2d.position.x = -57
	#Attack Mechanism
	if sprite_2d.animation == "attacking":
		sprite_2d.position.x = -87

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()



func _on_attack_player_detector_body_entered(body):
	sprite_2d.play("attacking")
	velocity.x = 0
	sprite_2d.position.x = -87


func _on_attack_player_detector_body_exited(body):
	sprite_2d.play("Idle")
	sprite_2d.position.x = -57
	

func _on_player_detector_body_entered(body):
	sprite_2d.play("idle")
	if body.get_name() == "Player":
		if facing_right:
			sprite_2d.play("running")
			velocity.x = speed
		else:
			sprite_2d.play("running")
			velocity.x = -speed



func _on_player_detector_body_exited(body):
	sprite_2d.play("Idle")
	velocity.x = 0
