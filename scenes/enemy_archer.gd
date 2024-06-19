extends CharacterBody2D

signal arrow_shoot(arrow_scene, location)

const PICKUP = preload("res://scenes/Pickup.tscn")
const ARROW_SCENE = preload("res://Arrow.tscn")

@onready var archer_sprite_2d = $AnimatedSprite2D
@onready var archer_health_bar = $HealthBar

const speed = 150.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = false
var hp = 100
var is_attacking = false
var movement_vector = Vector2.ZERO

@onready var timer = $Timer

# Exporting an array of DropData
@export var drops: Array[DropData] = []

func _ready():
	timer.connect("timeout", self._on_timer_timeout)
	timer.start()
	# Initialize the health bar
	archer_health_bar.max_value = 100
	archer_health_bar.value = hp

func reduce_health(amount: int):
	archer_health_bar.value -= amount
	if archer_health_bar.value <= 0:
		die()

func die():
	queue_free()
	var pickup_instance = PICKUP.instantiate()
	pickup_instance.position = position 
	get_tree().root.add_child(pickup_instance)

func drop_items():
	for drop_data in drops:
		var drop_count = drop_data.get_drop_count()
		for i in range(drop_count):
			var item_instance = ItemData.new()
			item_instance.item_name = drop_data.item_name
			item_instance.item_sprite = drop_data.item_sprite
			item_instance.description = drop_data.description

			var pickup_instance = PICKUP.instantiate()
			pickup_instance.position = global_position
			pickup_instance.set_item(item_instance)
			get_parent().add_child(pickup_instance)

func shoot():
	# When it reaches frame 9, it will spawn arrows
	if archer_sprite_2d.frame == 9 and is_attacking:
		is_attacking = false  # Prevent further arrow spawning in this attack cycle
		var arrow_instance = ARROW_SCENE.instantiate()

		# Check if the archer is flipped and adjust the arrow position accordingly
		if archer_sprite_2d.flip_h:
			arrow_instance.global_position = $ArrowProjectile.global_position + Vector2(-10, 0)
		else:
			arrow_instance.global_position = $ArrowProjectile.global_position + Vector2(10, 0)

		arrow_instance.facing_right = not archer_sprite_2d.flip_h
		get_parent().add_child(arrow_instance)

func _physics_process(delta: float):
	# Idling Position
	if archer_sprite_2d.animation == "idle":
		archer_sprite_2d.position.x = -57
		if not archer_sprite_2d.flip_h:
			archer_sprite_2d.position.x = -51
	# Attack Mechanism
	if archer_sprite_2d.animation == "attacking":
		archer_sprite_2d.position.x = -87
		if not archer_sprite_2d.flip_h:
			archer_sprite_2d.position.x = -19

# Apply gravity
	if not is_on_floor():
		movement_vector.y += gravity * delta

	if not $RayCast2D.is_colliding() and is_on_floor():
		flip()
		movement_vector.x = speed if facing_right else -speed
	if movement_vector.x!= 0:
		archer_sprite_2d.play("running")
	move_and_slide()

	# Call shoot if the archer is attacking
	if is_attacking:
		timer.wait_time = 1.5
		shoot()

func _on_player_detector_body_entered(body):
	archer_sprite_2d.play("idle")
	if body.get_name() == "Player":
		movement_vector.x = speed if facing_right else -speed

func _on_attack_player_detector_body_entered(body):
	archer_sprite_2d.play("attacking")
	movement_vector.x = 0
	timer.wait_time = 1.5
	is_attacking = true  # Start attacking

func _on_attack_player_detector_body_exited(body):
	archer_sprite_2d.play("idle")
	archer_sprite_2d.position.x = -57
	is_attacking = false  # Stop attacking

func _on_player_detector_body_exited(body):
	archer_sprite_2d.play("idle")
	movement_vector.x = 0

func flip():
	facing_right =!facing_right

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
