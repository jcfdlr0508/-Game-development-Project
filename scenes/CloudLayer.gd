extends ParallaxLayer

@export var CLOUD_SPEED = -25
func _process(delta) -> void:
	self.motion_offset.x += CLOUD_SPEED * delta
