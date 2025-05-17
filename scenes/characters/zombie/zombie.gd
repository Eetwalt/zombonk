extends Area2D

var arrow = load("res://assets/ui/cursor.png")
var arrow_down = load("res://assets/ui/cursor_shot.png")

signal whacked(zombie: PackedScene, hole: PackedScene)
signal attacked(zombie: PackedScene, hole: PackedScene)

@onready var audio_raising: AudioStreamPlayer = $AudioStreamPlayer_Raising
@onready var audio_dying: AudioStreamPlayer = $AudioStreamPlayer_Dying
@onready var gunshot: AudioStreamPlayer = $Gunshot

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var uptime_timer: Timer = $UptimeTimer
@onready var game = get_parent().get_parent().get_parent().get_parent()

var parent_hole = null
var is_active: bool = false
var was_shot: bool = false

func _ready() -> void:
	game.game_over.connect(_on_game_over)
	visible = false

func set_hole(hole) -> void:
	parent_hole = hole

func appear() -> void:
	visible = true
	is_active = true
	animated_sprite_2d.play("raise")
	uptime_timer.start()
	audio_raising.play()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not is_active:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.set_custom_mouse_cursor(arrow_down, Input.CURSOR_ARROW, Vector2(32, 32))
			is_active = false
			was_shot = true
			uptime_timer.stop()
			audio_raising.stop()
			audio_dying.play()
			animated_sprite_2d.play("shot")
			whacked.emit(self, parent_hole)
			animated_sprite_2d.connect("animation_finished", Callable(self, "_on_shot_animation_finished"))
			
			await get_tree().create_timer(0.2).timeout
			Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW, Vector2(32, 32))
			

func _on_uptime_timer_timeout() -> void:
	if not is_active:
		return
	
	animated_sprite_2d.play("turn")
	await get_tree().create_timer(1).timeout
	
	if was_shot:
		return
	
	is_active = false
	animated_sprite_2d.play("attack")
	attacked.emit(self, parent_hole)
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))

func _on_shot_animation_finished() -> void:
	queue_free()
	
func _on_attack_animation_finished() -> void:
	queue_free()

func _on_game_over() -> void:
	is_active = false
	was_shot = false
	animated_sprite_2d.play("dive")
	await get_tree().create_timer(3.0).timeout
	queue_free()
