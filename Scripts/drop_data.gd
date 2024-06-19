extends Resource

class_name DropData

@export var item: String  # Example property, adjust as per your item data
@export var drop_chance: float = 1.0  # Chance to drop (1.0 = 100%)

func get_drop_count() -> int:
	# Logic to determine how many items to drop, e.g., based on chance
	if randf() <= drop_chance:
		return 1
	return 0
