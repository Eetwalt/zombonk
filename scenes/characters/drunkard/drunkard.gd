class_name Drunkard
extends Area2D

signal whacked(drunkard: PackedScene, hole: Node2D)

@onready var audio_raising: AudioStreamPlayer = $AudioStreamPlayer_Raising
@onready var audio_dying: AudioStreamPlayer = $AudioStreamPlayer_Dying

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var uptime_timer: Timer = $UptimeTimer
@onready var game = get_tree().get_first_node_in_group("game")

var parent_hole = null
var is_active: bool = false
var was_shot: bool = false

func _ready() -> void:
	visible = false
	game.game_over.connect(_on_game_over)

func set_hole(hole) -> void:
	parent_hole = hole

func appear() -> void:
	visible = true
	is_active = true
	animated_sprite_2d.play("raise")
	uptime_timer.start()
	audio_raising.play()

func get_shot(shooter_node: Node = null) -> void:
	if not is_active:
		return
	
	is_active = false
	was_shot = true
	uptime_timer.stop()
	audio_raising.stop()
	audio_dying.play()
	animated_sprite_2d.play("shot")
	whacked.emit(self, parent_hole)
	await animated_sprite_2d.animation_finished
	_on_shot_animation_finished()

func _on_uptime_timer_timeout() -> void:
	if not is_active:
		return
	
	is_active = false
	animated_sprite_2d.play("dive")
	await animated_sprite_2d.animation_finished
	_on_shot_animation_finished()

func _on_shot_animation_finished() -> void:
	queue_free()

func _on_game_over(reason: String) -> void:
	is_active = false
	was_shot = false
	uptime_timer.stop()
	if is_instance_valid(animated_sprite_2d):
		animated_sprite_2d.play("dive")
		await get_tree().create_timer(3.0).timeout
		queue_free()
	if is_instance_valid(self):
		queue_free()
