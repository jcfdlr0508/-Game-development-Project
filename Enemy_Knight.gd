extends CharacterBody2D

var speed = 150.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()

	velocity.x = speed if facing_right else -speed
	move_and_slide()

func flip():
	facing_right = !facing_right
	$Sprite.scale.x *= -1
