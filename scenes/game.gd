extends Node2D

@onready var zombie_hand_scene = preload("res://scenes/characters/zombie_hand/zombie_hand.tscn")

signal score_updated
signal lives_updated

var score: int = 0
var lives: int = 3

func spawn_new_hand(spawn_position, hole_node):
	var hand_instance = zombie_hand_scene.instantiate()
	hole_node.add_child(hand_instance)
	hand_instance.position = Vector2.ZERO
	
	hand_instance.whacked.connect(_on_hand_whacked.bind(hole_node))
	hand_instance.escaped.connect(_on_hand_escaped.bind(hole_node))
	
	var hand_uptime = 5.0
	hand_instance.pop_up(hand_uptime)
	
	hole_node.set_occupied(true, hand_instance)


func _on_hand_whacked(hole_that_had_hand) -> void:
	score += 1
	print("Score: ", score)
	score_updated.emit()
	
	if hole_that_had_hand and hole_that_had_hand.has_method("set_occupied"):
		hole_that_had_hand.set_occupied(false, null)

func _on_hand_escaped(hole_that_had_hand) -> void:
	lives -= 1
	print("Lives remaining: ", lives)
	
	if hole_that_had_hand and hole_that_had_hand.has_method("set_occupied"):
		hole_that_had_hand.set_occupied(false, null)
		
	if lives <= 0:
		game_over()

func game_over() -> void:
	print("Game over")
	get_tree().paused = true
