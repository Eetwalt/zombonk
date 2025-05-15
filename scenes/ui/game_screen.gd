extends CanvasLayer

signal play_again

@onready var game_container: PanelContainer = $GameContainer
@onready var game_over_container: PanelContainer = $GameOverContainer
@onready var main_menu_container: PanelContainer = $MainMenuContainer

@onready var score_label: Label = $GameContainer/MarginContainer/ScoreLabelContainer/MarginContainer/ScoreLabel
@onready var hearts_container: HBoxContainer = $GameContainer/MarginContainer/VBoxContainer/HeartsPanelContainer/MarginContainer/HeartsContainer
@onready var warnings_container: HBoxContainer = $GameContainer/MarginContainer/VBoxContainer/WarningsPanelContainer/MarginContainer/WarningsContainer

@onready var heart: PackedScene = preload("res://scenes/objects/heart.tscn")
@onready var heart_empty: PackedScene = preload("res://scenes/objects/heart_empty.tscn")

@onready var badge: PackedScene = preload("res://scenes/objects/badge.tscn")
@onready var badge_empty: PackedScene = preload("res://scenes/objects/badge_empty.tscn")

@onready var final_score_label: Label = $GameOverContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/FinalScoreLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blood_overlay: TextureRect = $BloodOverlay


var hearts: Array = []

func _ready() -> void:
	_on_main_menu()
	blood_overlay.material.set_shader_parameter("opacity", 0.0)
	
	var game = get_parent()
	if game:
		game.score_updated.connect(_on_score_updated)
		game.lives_updated.connect(_on_lives_updated)
		game.warnings_updated.connect(_on_warnings_updated)
		game.game_over.connect(_on_game_over)

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)
	final_score_label.text = "Final score: " + str(new_score)

func _on_lives_updated(current_lives: int) -> void:
	if current_lives < 3:
		animation_player.play("blood_splatter")

	set_hearts(current_lives)

func set_hearts(current_lives: int) -> void:
	var previous_lives = hearts_container.get_children()
	
	for i in previous_lives:
		i.queue_free()
	
	var max_lives = 3
	var empty_lives = max_lives - current_lives

	for i in current_lives:
		var new_heart = heart.instantiate()
		hearts_container.add_child(new_heart)

	for i in empty_lives:
		if i < max_lives:
			var new_heart_empty = heart_empty.instantiate()
			hearts_container.add_child(new_heart_empty)

func _on_warnings_updated(current_warnings: int) -> void:
	set_warnings(current_warnings)

func set_warnings(current_warnings: int) -> void:
	for child in warnings_container.get_children():
		child.queue_free()
	
	var max_warnings = 3
	
	var warnings_to_show = clamp(current_warnings, 0, max_warnings)
	
	for i in range(warnings_to_show):
		if badge:
			var new_badge = badge.instantiate()
			warnings_container.add_child(new_badge)
		else:
			printerr("Warning: 'badge' PackedScene is not set!")
		
	var empty_badges = max_warnings - warnings_to_show
	for i in range(empty_badges):
		if badge_empty:
			var new_badge_empty = badge_empty.instantiate()
			warnings_container.add_child(new_badge_empty)
		else:
			printerr("Warning: 'badge_empty' PackedScene is not set!")

func _on_main_menu() -> void:
	game_container.visible = false
	game_over_container.visible = false
	main_menu_container.visible = true
	blood_overlay.visible = false

func _on_game_over() -> void:
	game_container.visible = false
	game_over_container.visible = true
	main_menu_container.visible = false
	blood_overlay.visible = false

func _on_game_play() -> void:
	game_container.visible = true
	game_over_container.visible = false
	main_menu_container.visible = false
	blood_overlay.visible = true

func _on_play_again_button_pressed() -> void:
	play_again.emit()
	_on_game_play()


func _on_main_menu_button_pressed() -> void:
	_on_main_menu()
