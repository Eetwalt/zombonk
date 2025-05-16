extends Area2D

var arrow = load("res://assets/ui/cursor.png")
var arrow_down = load("res://assets/ui/cursor_shot.png")

signal whacked(drunkard: PackedScene, hole: PackedScene)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var uptime_timer: Timer = $UptimeTimer
@onready var game = get_parent().get_parent().get_parent().get_parent()

var parent_hole = null
var is_active: bool = false

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

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not is_active:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.set_custom_mouse_cursor(arrow_down, Input.CURSOR_ARROW, Vector2(32, 32))
			is_active = false
			uptime_timer.stop()
			animated_sprite_2d.play("shot")
			whacked.emit(self, parent_hole)
			animated_sprite_2d.connect("animation_finished", Callable(self, "_on_shot_animation_finished"))
			
			await get_tree().create_timer(0.2).timeout
			Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW, Vector2(32, 32))
			

func _on_uptime_timer_timeout() -> void:
	if not is_active:
		return
	
	is_active = false
	animated_sprite_2d.play("dive")
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_shot_animation_finished"))

func _on_shot_animation_finished() -> void:
	queue_free()

func _on_game_over() -> void:
	is_active = false
	animated_sprite_2d.play("dive")
	await get_tree().create_timer(3.0).timeout
	queue_free()
