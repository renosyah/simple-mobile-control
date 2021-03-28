extends Node

signal on_joystick_move(position)

func _ready():
	pass

func _on_touchscreen_input_joystick(position):
	emit_signal("on_joystick_move",position)
