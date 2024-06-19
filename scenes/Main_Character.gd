extends CharacterBody2D
class_name Player

@onready var sprite_2d = $Sprite2D
@onready var player_health_bar = $HealthBar
@onready var pause_menu = $"Pause Menu"
@onready var lives_score = $Control/Lives

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DOUBLE_JUMP_VELOCITY = -450.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump = false
var isAttacking = false
var isBlocking = false
var hp = 100
var paused = false
var lives = 3
var respawn_point = Vector2(-278, 285)

func _ready():
	GameManager.player = self
	player_health_bar.max_value = 100
	player_health_bar.value = hp
	lives_score.text = "x" + str(lives)
	# Connect checkpoint signal if not connected via editor
	# $Checkpoint.connect("body_entered", self, "_on_checkpoint_body_entered")

func reduce_health(amount):
	if not isBlocking:
		hp -= amount
		player_health_bar.value = hp
		print("Reduced health by", amount, "Current HP:", hp)
		if hp <= 0:
			die()

func increase_health(amount):
	hp += amount
	if hp > 100:
		hp = 100
	player_health_bar.value = hp

func increase_lives(amount):
	lives += amount
	lives_score.text = "x" + str(lives)  # Update the UI to reflect the new lives

func die():
	lives -= 1
	print("Died. Remaining lives:", lives)
	lives_score.text = "x" + str(lives)
	if lives >= 0:
		GameManager.respawn_player()
		respawn()
	else:
		print("Game Over")
		get_tree().change_scene_to_file("res://gameover_screen.tscn")
		queue_free()

func respawn():
	if GameManager.current_checkpoint and not GameManager.current_checkpoint.is_queued_for_deletion():
		position = GameManager.current_checkpoint.position + Vector2(0, -285)
	else:
		position = respawn_point
	hp = 100
	player_health_bar.value = hp

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0

	paused = !paused

func _physics_process(delta):
	if sprite_2d.animation == "attack1" and is_on_floor():
		return
	elif sprite_2d.animation == "attack1" and not is_on_floor():
		velocity.y += gravity * delta
	if sprite_2d.animation == "blocking" and is_on_floor():
		return
	elif sprite_2d.animation == "blocking" and not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("Pause"):
		pauseMenu()

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
				velocity.y = DOUBLE_JUMP_VELOCITY
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
			velocity.x = 0

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

func _on_attack_area_body_entered(body):
	if body.get_name() == "Enemy-Knight":
		if not isBlocking:
			body.reduce_health(35)
	elif body.get_name() == "Enemy-Archer":
		if not isBlocking:
			body.reduce_health(50)

func _on_fall_death_body_entered(body):
	if body.get_name() == "Player":
		reduce_health(100)

func _on_checkpoint_body_entered(body):
	if body is Checkpoint:
		if not body.activated:
			body.activate()
			GameManager.current_checkpoint = body

func change_level(new_level_path):
	GameManager.reset_checkpoint()
	get_tree().change_scene_to_file(new_level_path)
