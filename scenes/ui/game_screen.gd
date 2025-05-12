extends CanvasLayer

signal play_again

@onready var game_container: PanelContainer = $GameContainer
@onready var game_over_container: PanelContainer = $GameOverContainer

@onready var score_label: Label = $GameContainer/MarginContainer/ScoreLabelContainer/MarginContainer/ScoreLabel
@onready var hearts_container: HBoxContainer = $GameContainer/MarginContainer/HeartsPanelContainer/MarginContainer/HeartsContainer

@onready var heart: PackedScene = preload("res://scenes/objects/heart.tscn")
@onready var heart_empty: PackedScene = preload("res://scenes/objects/heart_empty.tscn")

var hearts: Array = []

func _ready() -> void:
	_on_game_play()
	
	var game = get_parent()
	if game:
		game.score_updated.connect(_on_score_updated)
		game.lives_updated.connect(_on_lives_updated)
		game.game_over.connect(_on_game_over)

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)

func _on_lives_updated(current_lives: int) -> void:
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

func _on_game_over() -> void:
	game_container.visible = false
	game_over_container.visible = true

func _on_game_play() -> void:
	game_container.visible = true
	game_over_container.visible = false

func _on_play_again_button_pressed() -> void:
	play_again.emit()
	_on_game_play()
