extends Node2D

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var character_holder: Node = $CharacterHolder
@onready var tombstone: Sprite2D = $Tombstone

var stones: Array = ["stone1", "stone2", "stone3"] 
var current_character = null

func _ready() -> void:
	var stone = stones.pick_random()
	tombstone.texture = load("res://assets/game/objects/" + stone + ".png")

func is_occupied() -> bool:
	return current_character != null and is_instance_valid(current_character)

func add_character(character_instance) -> void:
	if not is_occupied():
		current_character = character_instance
		character_holder.add_child(current_character)
		current_character.global_position = spawn_point.global_position
		
		current_character.appear()
	else:
		print("Warning: Tried to add zombie to occupied hole")
		character_instance.queue_free()
