extends CharacterBody2D

signal arrow_shoot(arrow_scene, locatio)

@onready var archer_sprite_2d = $AnimatedSprite2D
@onready var archer_health_bar = $HealthBar
@onready var arrow = $ArrowProjectile
@onready var arrow_scene = preload("res://Arrow.tscn")
var a

const speed = 150.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = false
var player = load("res://scenes/Main_Character.gd")
var hp = 100

func _ready():
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
	if archer_sprite_2d.frame == 9:
		var arrow_scene = preload("res://Arrow.tscn")
		var arrow_instance = arrow_scene.instantiate()
		arrow_instance.set_position($ArrowProjectile.global_position)
		get_parent().add_child(arrow_instance)

func _physics_process(delta):
	#Idling Position
	if archer_sprite_2d.animation == "idle":
		archer_sprite_2d.position.x = -57
		if archer_sprite_2d.flip_h == false:
			archer_sprite_2d.position.x = -51
	#Attack Mechanism
	if archer_sprite_2d.animation == "attacking":
		archer_sprite_2d.position.x = -87
		if archer_sprite_2d.flip_h == false:
			archer_sprite_2d.position.x = -19
	
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
		archer_sprite_2d.play("running")
	move_and_slide()
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

func _on_attack_player_detector_body_exited(body):
	archer_sprite_2d.play("idle")
	archer_sprite_2d.position.x = -57

func _on_player_detector_body_exited(body):
	archer_sprite_2d.play("idle")
	velocity.x = 0

func flip():
	facing_right = !facing_right
	
	if facing_right:
		archer_sprite_2d.flip_h = false
		$RayCast2D.position.x = 256
		$"Attack Player Detector/CollisionShape2D".position.x = 901
	else:
		archer_sprite_2d.flip_h = true
		$RayCast2D.position.x = 223
		$"Attack Player Detector/CollisionShape2D".position.x = 633
