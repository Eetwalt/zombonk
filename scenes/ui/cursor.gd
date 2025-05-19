extends Node2D

var arrow = load("res://assets/ui/cursor.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW, Vector2(32, 32))
