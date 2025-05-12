extends Node

var arrow = load("res://assets/ui/arrow.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW, Vector2(32, 32))
