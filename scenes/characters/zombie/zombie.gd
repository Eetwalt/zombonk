extends Area2D

signal whacked(zombie: PackedScene, hole: PackedScene)
signal escaped(zombie: PackedScene, hole: PackedScene)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var uptime_timer: Timer = $UptimeTimer

var parent_hole = null
var is_active: bool = false

func _ready() -> void:
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
			is_active = false
			uptime_timer.stop()
			animated_sprite_2d.play("decent")
			whacked.emit(self, parent_hole)
			animated_sprite_2d.connect("animation_finished", Callable(self, "_on_decent_animation_finished"))

func _on_uptime_timer_timeout() -> void:
	if not is_active:
		return
	
	is_active = false
	animated_sprite_2d.play("decent")
	escaped.emit(self, parent_hole)
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_decent_animation_finished"))

func _on_decent_animation_finished() -> void:
	queue_free()
