extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var player_health_bar = $HealthBar


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const double_jump_velocity = -450.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump = false
var isAttacking = false
var isBlocking = false
var player = load("res://scenes/enemy_knight.tscn")
var hp = 100

func _ready():
	# Initialize the health bar
	player_health_bar.max_value = 100
	player_health_bar.value = hp
	
func reduce_health(amount):
	player_health_bar.value -= amount
	if player_health_bar.value <= 0:
		die()

func die():
	queue_free()
	# Add any additional logic for when the player dies

func _physics_process(delta):
	if sprite_2d.animation == "attack1" and is_on_floor():
		return
	elif sprite_2d.animation == "attack1" and not is_on_floor():
		velocity.y += gravity * delta
	if sprite_2d.animation == "blocking" and is_on_floor():
		return
	elif sprite_2d.animation == "blocking" and not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("Attacking"):
		sprite_2d.play("attack1")
		isAttacking = true
		isBlocking = false
		$AttackArea/CollisionShape2D.disabled = false
		

	if Input.is_action_just_pressed("Blocking"):
		sprite_2d.play("blocking")
		isBlocking = true

	if not isAttacking and not isBlocking:
		if (velocity.x > 1 or velocity.x < -1):
			sprite_2d.play("running")
		else:
			sprite_2d.play("idle")

		if not is_on_floor():
			velocity.y += gravity * delta
			sprite_2d.play("jumping")
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
			if sprite_2d.flip_h:
				$AttackArea/CollisionShape2D.position.x = 64
			else:
				$AttackArea/CollisionShape2D.position.x = 182
			sprite_2d.animation = "running"
		else:
			if is_on_floor():
				sprite_2d.animation = "idle"
			velocity.x = 0  # Stop horizontal movement when no input

	move_and_slide()

func _input(event):
	if event.is_action_released("Blocking"):
		isBlocking = false
		sprite_2d.play("idle")

func _on_sprite_2d_animation_finished():
	if sprite_2d.animation == "attack1":
		sprite_2d.stop()
		isAttacking = false
		sprite_2d.animation = "idle"
		$AttackArea/CollisionShape2D.disabled = true

#Enemy's Hurtbox
func _on_attack_area_body_entered(body):
		if body.get_name() == "Enemy-Knight":
			body.reduce_health(35)
			if isBlocking:
				body.reduce_health(0)
		elif body.get_name() == "Enemy-Archer":
			body.reduce_health(50)
			if isBlocking:
				body.reduce_health(0)
		
