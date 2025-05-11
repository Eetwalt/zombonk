extends Area2D

signal whacked
signal escaped

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var uptime_timer: Timer = $UptimeTimer

@export var uptime: int = 5

var is_hittable: bool = false

func _ready() -> void:
	uptime_timer.set("wait_time", uptime)
	hide_hand()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not is_hittable:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			process_hit()

func pop_up(duration_seconds: int) -> void:
	visible = true
	collision_shape_2d.disabled = false
	is_hittable = true
	uptime_timer.start(duration_seconds)
	print("hand popped up")

func hide_hand(was_whacked: bool = false) -> void:
	is_hittable = false
	visible = false
	collision_shape_2d.disabled = true
	
	if not was_whacked and uptime_timer.is_stopped():
		pass
	queue_free()

func process_hit() -> void:
	if not is_hittable:
		return
	
	is_hittable = false
	uptime_timer.stop()
	animated_sprite_2d.play("decent")
	whacked.emit()
	hide_hand(true)

func on_escaped() -> void:
	escaped.emit()


func _on_uptime_timer_timeout() -> void:
	if is_hittable:
		is_hittable = false
		print("hand escaped")
		escaped.emit()
		hide_hand()
