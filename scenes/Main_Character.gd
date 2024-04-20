extends CharacterBody2D

@onready var sprite_2d = $Sprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const double_jump_velocity = -450.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump = false
var isAttacking = false

func _physics_process(delta):
	if Input.is_action_just_pressed("Attacking"):
		sprite_2d.play("attack1")
		isAttacking = true
		$AttackArea/CollisionShape2D.disabled = false
		$AttackArea/CollisionShape2D2.disabled = false

	if not isAttacking:
		if (velocity.x > 1 or velocity.x < -1):
			sprite_2d.play("running")
			isAttacking = false
			
		else:
			sprite_2d.play("idle")

		if not is_on_floor():
			velocity.y += gravity * delta
			sprite_2d.animation = "jumping"
		else:
			has_double_jump = false

		if Input.is_action_just_pressed("Jump"):
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
			elif not has_double_jump:
				velocity.y = double_jump_velocity
				has_double_jump = true

		var direction = Input.get_axis("Left", "Right")
		if direction:
			velocity.x = direction * SPEED
			sprite_2d.flip_h = direction < 0
			sprite_2d.animation = "running"
			isAttacking = false
		else:
			if is_on_floor():
				sprite_2d.animation = "idle"
			velocity.x = 0  # Stop horizontal movement when no input

	move_and_slide()


func _on_sprite_2d_animation_finished():
	if sprite_2d.animation == "attack1":
		sprite_2d.stop()
		isAttacking = false
		sprite_2d.animation = "idle"
		$AttackArea/CollisionShape2D.disabled =true
		$AttackArea/CollisionShape2D2.disabled =true

