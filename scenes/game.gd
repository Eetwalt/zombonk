extends Node2D

signal score_updated(new_score)
signal lives_updated(new_lives)
signal warnings_updated(new_warnings)
signal game_over(reason: String)
signal gun_state_changed(is_loaded: bool)

var score: int = 0
var lives: int = 3
var warnings: int = 0

var min_spawn_interval = 0.5
var max_spawn_interval = 2.0

var arrow = load("res://assets/ui/cursor.png")
var arrow_down = load("res://assets/ui/cursor_shot.png")

var game_screen_state = "menu"

var zombie_scene = preload("res://scenes/characters/zombie/zombie.tscn")
var drunkard_scene = preload("res://scenes/characters/drunkard/drunkard.tscn")

var holes: Array = []
var characters: Array = ["zombie", "drunkard"]

var can_shoot_now: bool = true

@onready var hole_container: Node2D = $HoleContainer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var game_timer: Timer = $GameTimer

@onready var gunshot: AudioStreamPlayer = $Gunshot
@onready var rack: AudioStreamPlayer = $Rack

@onready var reload_bar: Sprite2D = $Cursor/ReloadBar
@onready var reload_bar_fill: ColorRect = $Cursor/ReloadBar/ReloadBarFill
@onready var reload_timer: Timer = $Cursor/ReloadTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var reload_bar_offset: Vector2 = Vector2(20, 20)
@export var game_screen: CanvasLayer

func _ready() -> void:
	game_screen.play_again.connect(start_new_game)
	game_screen.game_screen_updated.connect(_on_game_scren_updated)
	reload_bar.hide()
	
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
	
	if random_value < 0.80:
		spawn_character(zombie_scene, chosen_hole, "zombie")
	else:
		spawn_character(drunkard_scene, chosen_hole, "drunkard")

func spawn_character(character_scene: PackedScene, chosen_hole: Node2D, character_name: String) -> void:
	var new_character = character_scene.instantiate()
	
	var whacked_function = "_on_" + character_name + "_whacked"
	new_character.connect("whacked", Callable(self, whacked_function))
	
	if character_name == "zombie":
		var attacked_function = "_on_" + character_name + "_attacked"
		new_character.connect("attacked", Callable(self, attacked_function))

	new_character.set_hole(chosen_hole)
	chosen_hole.add_character(new_character)

func _on_zombie_whacked(_zombie_instance, _hole_instance) -> void:
	score += 1
	score_updated.emit(score)

func _on_zombie_attacked(_zombie_instance, _hole_instance) -> void:
	lives -= 1
	lives_updated.emit(lives)
	if lives <= 0:
		_on_game_over("died")

func _on_drunkard_whacked(_drunkard_instance, _hole_instance) -> void:
	warnings += 1
	warnings_updated.emit(warnings)
	if warnings >= 3:
		_on_game_over("jailed")

func _on_game_timer_timeout() -> void:
	if min_spawn_interval <= 0.0:
		min_spawn_interval = 0.0
	else:
		min_spawn_interval -= 0.1
	
	if max_spawn_interval <= 0.5:
		max_spawn_interval = 0.5
	else:
		max_spawn_interval -= 0.1

func _on_game_over(reason: String) -> void:
	game_over.emit(reason)
	spawn_timer.stop()
	game_timer.stop()
	min_spawn_interval = 0.5
	max_spawn_interval = 2.0

func _process(delta: float) -> void:
	reload_bar.global_position = get_global_mouse_position()


func _on_reload_timer_timeout() -> void:
	reload_bar.hide()
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW, Vector2(32, 32))
	can_shoot_now = true
	gun_state_changed.emit(true)

func _input(event: InputEvent) -> void:
	if game_screen_state == "game":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_shoot_now:
				can_shoot_now = false
				gun_state_changed.emit(false)
				
				Input.set_custom_mouse_cursor(arrow_down, Input.CURSOR_ARROW, Vector2(32, 32))
				reload_bar.show()
				reload_timer.start()
				animation_player.play("Reload Bar Filling")
				
				gunshot.play()
				rack.play()
				
				var mouse_pos = get_global_mouse_position()
				var space_state = get_world_2d().direct_space_state
				var query = PhysicsPointQueryParameters2D.new()
				query.position = mouse_pos
				query.collide_with_areas = true
				query.collision_mask = 1
				var results = space_state.intersect_point(query)
				if not results.is_empty():
					var hit_collider = results[0].collider
					if hit_collider is Area2D and hit_collider.has_method("get_shot"):
						if hit_collider.is_active:
							hit_collider.get_shot(self)
			else:
				pass

func _on_game_scren_updated(game_screen) -> void:
	game_screen_state = game_screen
