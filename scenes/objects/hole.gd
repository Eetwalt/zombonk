extends Node2D

@onready var spawn_point: Marker2D = $SpawnPoint

var current_zombie = null

func is_occupied() -> bool:
	return current_zombie != null and is_instance_valid(current_zombie)

func add_zombie(zombie_instance) -> void:
	if not is_occupied():
		current_zombie = zombie_instance
		add_child(current_zombie)
		current_zombie.global_position = spawn_point.global_position
		
		current_zombie.appear()
	else:
		print("Warning: Tried to add zombie to occupied hole")
		zombie_instance.queue_free()
