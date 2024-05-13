extends CharacterBody2D

@onready var sprite_2d = $AnimatedSprite2D

const speed = 150.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = false

func _physics_process(delta):
	#Idling Position
	if sprite_2d.animation == "idle":
		sprite_2d.position.x = -57
		if sprite_2d.flip_h == false:
			sprite_2d.position.x = -51
	#Attack Mechanism
	if sprite_2d.animation == "attacking":
		sprite_2d.position.x = -87
		if sprite_2d.flip_h == false:
			sprite_2d.position.x = -19
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()
		if facing_right:
			velocity.x = speed
		else:
			velocity.x = -speed
	if velocity.x !=0:
		sprite_2d.play("running")
	move_and_slide()

func _on_player_detector_body_entered(body):
	sprite_2d.play("idle")
	if body.get_name() == "Player":
		if facing_right:
			sprite_2d.play("running")
			velocity.x = speed
		else:
			sprite_2d.play("running")
			velocity.x = -speed

func _on_attack_player_detector_body_entered(body):
	sprite_2d.play("attacking")
	velocity.x = 0
	sprite_2d.position.x = -87
	

func _on_attack_player_detector_body_exited(body):
	sprite_2d.play("idle")
	sprite_2d.position.x = -57

func _on_player_detector_body_exited(body):
	sprite_2d.play("idle")
	velocity.x = 0

func flip():
	facing_right = !facing_right
	
	if facing_right:
		sprite_2d.flip_h = false
		$RayCast2D.position.x = 256
		$"Attack Player Detector/CollisionShape2D".position.x = 901
	else:
		sprite_2d.flip_h = true
		$RayCast2D.position.x = 223
		$"Attack Player Detector/CollisionShape2D".position.x = 633
