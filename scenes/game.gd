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
var zombie_scene = preload("res://scenes/characters/zombie/zombie.tscn")

var holes: Array = []

func _ready() -> void:
	var game_screen = get_child(1)
	game_screen.play_again.connect(start_new_game)
	
	for hole_node in hole_container.get_children():
		if hole_node is Node2D:
			holes.append(hole_node)
	
	start_new_game()

func start_new_game() -> void:
	score = 0
	lives = 3
	score_updated.emit(score)
	lives_updated.emit(lives)
	
	for h in holes:
		var existing_zombie = h.get_node_or_null("Zombie")
		if existing_zombie:
			existing_zombie.queue_free()
	_start_spawn_timer()

func _start_spawn_timer() -> void:
	spawn_timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	spawn_zombie()
	_start_spawn_timer()
	
func spawn_zombie() -> void:
	var available_holes = []
	for h in holes:
		if not h.is_occupied():
			available_holes.append(h)
		
	if available_holes.is_empty():
		print("No available holes to spawn Zombies")
		return
	
	var chosen_hole = available_holes.pick_random()
	var new_zombie = zombie_scene.instantiate()
	
	new_zombie.connect("whacked", _on_zombie_whacked)
	new_zombie.connect("escaped", _on_zombie_escaped)
	
	new_zombie.set_hole(chosen_hole)
	
	chosen_hole.add_zombie(new_zombie)


func _on_zombie_whacked(_zombie_instance, _hole_instance) -> void:
	score += 1
	score_updated.emit(score)

func _on_zombie_escaped(_zombie_instance, _hole_instance) -> void:
	lives -= 1
	lives_updated.emit(lives)
	if lives <= 0:
		game_over.emit()
		spawn_timer.stop()
		print("GAME OVER")
