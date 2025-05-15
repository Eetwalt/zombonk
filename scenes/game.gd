extends Node2D

signal score_updated(new_score)
signal lives_updated(new_lives)
signal warnings_updated(new_warnings)
signal game_over

var score: int = 0
var lives: int = 3
var warnings: int = 0

var min_spawn_interval = 0.5
var max_spawn_interval = 2.0

@onready var hole_container: Node2D = $HoleContainer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var game_timer: Timer = $GameTimer

@export var game_screen: CanvasLayer

var zombie_scene = preload("res://scenes/characters/zombie/zombie.tscn")
var drunkard_scene = preload("res://scenes/characters/drunkard/drunkard.tscn")

var holes: Array = []
var characters: Array = ["zombie", "drunkard"]

func _ready() -> void:
	game_screen.play_again.connect(start_new_game)
	
	for hole_node in hole_container.get_children():
		if hole_node is Node2D:
			holes.append(hole_node)
	
	randomize()

func start_new_game() -> void:
	score = 0
	lives = 3
	warnings = 0
	score_updated.emit(score)
	lives_updated.emit(lives)
	warnings_updated.emit(warnings)
	
	for h in holes:
		var existing_zombie = h.get_node_or_null("Zombie")
		var existing_drunkard = h.get_node_or_null("Drunkard")
		if existing_zombie:
			existing_zombie.queue_free()
		if existing_drunkard:
			existing_drunkard.queue_free()
	_start_spawn_timer()
	game_timer.start()

func _start_spawn_timer() -> void:
	spawn_timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	allocate_hole()
	_start_spawn_timer()
	
func allocate_hole() -> void:
	var available_holes = []
	for h in holes:
		if not h.is_occupied():
			available_holes.append(h)
		
	if available_holes.is_empty():
		print("No available holes to spawn Characters")
		return
	
	var chosen_hole = available_holes.pick_random()
	
	var random_value: float = randf()
	print(random_value)
	
	if random_value < 0.70:
		spawn_character(zombie_scene, chosen_hole, "zombie")
	else:
		spawn_character(drunkard_scene, chosen_hole, "drunkard")

func spawn_character(character_scene: PackedScene, chosen_hole: Node2D, character_name: String) -> void:
	var new_character = character_scene.instantiate()
	
	var whacked_function = "_on_" + character_name + "_whacked"
	var escaped_function = "_on_" + character_name + "_escaped"
	
	new_character.connect("whacked", Callable(self, whacked_function))
	new_character.connect("escaped", Callable(self, escaped_function))

	new_character.set_hole(chosen_hole)

	chosen_hole.add_character(new_character)

func _on_zombie_whacked(_zombie_instance, _hole_instance) -> void:
	score += 1
	score_updated.emit(score)

func _on_zombie_escaped(_zombie_instance, _hole_instance) -> void:
	lives -= 1
	lives_updated.emit(lives)
	if lives <= 0:
		game_over.emit()
		spawn_timer.stop()
		game_timer.stop()

func _on_drunkard_whacked(_drunkard_instance, _hole_instance) -> void:
	warnings += 1
	warnings_updated.emit(warnings)
	if warnings >= 3:
		game_over.emit()
		spawn_timer.stop()
		game_timer.stop()

func _on_drunkard_escaped(_drunkard_instance, _hole_instance) -> void:
	pass


func _on_game_timer_timeout() -> void:
	if min_spawn_interval <= 0.0:
		min_spawn_interval = 0.0
	else:
		min_spawn_interval -= 0.1
	
	if max_spawn_interval <= 0.5:
		max_spawn_interval = 0.5
	else:
		max_spawn_interval -= 0.1
