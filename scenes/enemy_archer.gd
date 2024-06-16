extends CharacterBody2D

signal arrow_shoot(arrow_scene, location)

@onready var archer_sprite_2d = $AnimatedSprite2D
@onready var archer_health_bar = $HealthBar
@onready var arrow = $Arrow
@onready var arrow_scene = preload("res://Arrow.tscn")

const speed = 150.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = false
var player = load("res://scenes/Main_Character.gd")
var hp = 100
var is_attacking = false

@onready var timer = $Timer

func _ready():
	timer.start()
	# Initialize the health bar
	archer_health_bar.max_value = 100
	archer_health_bar.value = hp
	
func reduce_health(amount):
	archer_health_bar.value -= amount
	if archer_health_bar.value <= 0:
		die()

func die():
	queue_free()
	# Add any additional logic for when the player dies

func shoot():
	# When it reaches frame 9, it will spawn arrows
	if archer_sprite_2d.frame == 9 and is_attacking:
		is_attacking = false  # Prevent further arrow spawning in this attack cycle
		var arrow_instance = arrow_scene.instantiate()
		
		# Check if the archer is flipped and adjust the arrow position accordingly
		if archer_sprite_2d.flip_h:
			# Archer is flipped, so position the arrow to the left
			arrow_instance.global_position = $ArrowProjectile.global_position + Vector2(-10, 0) # Adjust the -10 value as needed
		else:
			# Archer is not flipped, so position the arrow to the right
			arrow_instance.global_position = $ArrowProjectile.global_position + Vector2(10, 0) # Adjust the 10 value as needed
		
		# Set the arrow's facing direction based on the archer's orientation
		arrow_instance.facing_right = not archer_sprite_2d.flip_h
		
		get_parent().add_child(arrow_instance)

func _physics_process(delta):
	# Idling Position
	if archer_sprite_2d.animation == "idle":
		archer_sprite_2d.position.x = -57
		if archer_sprite_2d.flip_h == false:
			archer_sprite_2d.position.x = -51
	# Attack Mechanism
	if archer_sprite_2d.animation == "attacking":
		archer_sprite_2d.position.x = -87
		if archer_sprite_2d.flip_h == false:
			archer_sprite_2d.position.x = -19
	
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	if !$RayCast2D.is_colliding() and is_on_floor():
		flip()
		if facing_right:
			velocity.x = speed
		else:
			velocity.x = -speed
	if velocity.x != 0:
		archer_sprite_2d.play("running")
	move_and_slide()

	# Call shoot if archer is attacking
	if is_attacking:
		timer.wait_time = 1.5
		shoot()

func _on_player_detector_body_entered(body):
	archer_sprite_2d.play("idle")
	if body.get_name() == "Player":
		if facing_right:
			archer_sprite_2d.play("running")
			velocity.x = speed
		else:
			archer_sprite_2d.play("running")
			velocity.x = -speed

func _on_attack_player_detector_body_entered(body):
	archer_sprite_2d.play("attacking")
	velocity.x = 0
	timer.wait_time = 1.5
	is_attacking = true  # Start attacking

func _on_attack_player_detector_body_exited(body):
	archer_sprite_2d.play("idle")
	archer_sprite_2d.position.x = -57
	is_attacking = false  # Stop attacking

func _on_player_detector_body_exited(body):
	archer_sprite_2d.play("idle")
	velocity.x = 0

func flip():
	facing_right = !facing_right
	
	if facing_right:
		archer_sprite_2d.flip_h = false
		$RayCast2D.position.x = 256
		$"Attack Player Detector/CollisionShape2D".position.x = 901
		$ArrowProjectile.position.x = 268

	else:
		archer_sprite_2d.flip_h = true
		$RayCast2D.position.x = 223
		$"Attack Player Detector/CollisionShape2D".position.x = 633
		$ArrowProjectile.position.x = 214

func _on_timer_timeout():
	timer.stop()
	$"Attack Player Detector/CollisionShape2D".disabled = true
	timer.start()
	$"Attack Player Detector/CollisionShape2D".disabled = false
