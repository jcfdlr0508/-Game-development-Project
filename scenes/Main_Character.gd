extends CharacterBody2D

@onready var sprite_2d = $Sprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const double_jump_velocity = -450.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump: bool =false


func _physics_process(delta):
	if (velocity.x > 1 or velocity.x <-1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "idle"
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		sprite_2d.animation = "jumping"
	else:
		has_double_jump = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		elif not has_double_jump:
			velocity.y =double_jump_velocity
			has_double_jump = true
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
