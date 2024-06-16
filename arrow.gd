extends Area2D

@onready var arrow_sprite = $ArrowSprite
@export var speed = 300
var facing_right = false

func _ready():
	# Ensure the arrow faces the correct direction
	if facing_right:
		arrow_sprite.flip_h = true
	else:
		arrow_sprite.flip_h = false

func _physics_process(delta):
	if facing_right:
		global_position.x += speed * delta
	else:
		global_position.x -= speed * delta

func _on_body_entered(body):
	if body.get_name() == "Player":
		body.reduce_health(5)
		queue_free()
