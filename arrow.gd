extends Area2D
@onready var arrow_sprite = $ArrowSprite

var facing_right = false
@export var speed = 300
func _physics_process(delta):
	global_position.x += -speed * delta
	if facing_right:
		global_position.x += speed * delta

func flip():
	facing_right = !facing_right
	
	if facing_right:
		arrow_sprite.flip_h = false
		global_position.x += speed
		$CollisionShape2D.position.x = 901
	else:
		arrow_sprite.flip_h = true
		$CollisionShape2D.position.x = 633
