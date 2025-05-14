extends Node2D

signal score_updated(new_score)
signal lives_updated(new_lives)
signal game_over

var score: int = 0
var lives: int = 3
var min_spawn_interval = 0.5
var max_spawn_interval = 2.0

@onready var hole_container: Node2D = $HoleContainer
@onready var spawn_timer: Timer = $SpawnTimer

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

func start_new_game() -> void:
	score = 0
	lives = 3
	score_updated.emit(score)
	lives_updated.emit(lives)
	
	for h in holes:
		var existing_zombie = h.get_node_or_null("Zombie")
		var existing_drunkard = h.get_node_or_null("Drunkard")
		if existing_zombie:
			existing_zombie.queue_free()
		if existing_drunkard:
			existing_drunkard.queue_free()
	_start_spawn_timer()

func _start_spawn_timer() -> void:
	spawn_timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	spawn_character()
	_start_spawn_timer()
	
func spawn_character() -> void:
	var available_holes = []
	for h in holes:
		if not h.is_occupied():
			available_holes.append(h)
		
	if available_holes.is_empty():
		print("No available holes to spawn Characters")
		return
	
	var chosen_hole = available_holes.pick_random()
	var character = characters.pick_random()
	if character == "zombie":
		var new_zombie = zombie_scene.instantiate()
	
		new_zombie.connect("whacked", _on_zombie_whacked)
		new_zombie.connect("escaped", _on_zombie_escaped)
	
		new_zombie.set_hole(chosen_hole)
	
		chosen_hole.add_character(new_zombie)
		
	if character == "drunkard":
		var new_drunkard = drunkard_scene.instantiate()
	
		new_drunkard.connect("whacked", _on_drunkard_whacked)
		new_drunkard.connect("escaped", _on_drunkard_escaped)
	
		new_drunkard.set_hole(chosen_hole)
	
		chosen_hole.add_character(new_drunkard)


func _on_zombie_whacked(_zombie_instance, _hole_instance) -> void:
	score += 1
	score_updated.emit(score)

func _on_zombie_escaped(_zombie_instance, _hole_instance) -> void:
	lives -= 1
	lives_updated.emit(lives)
	if lives <= 0:
		game_over.emit()
		spawn_timer.stop()

func _on_drunkard_whacked(_drunkard_instance, _hole_instance) -> void:
	lives -= 1
	lives_updated.emit(lives)
	if lives <= 0:
		game_over.emit()
		spawn_timer.stop()

func _on_drunkard_escaped(_drunkard_instance, _hole_instance) -> void:
	score += 1
	score_updated.emit(score)
