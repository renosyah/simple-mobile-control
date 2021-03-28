extends Node

signal on_joystick_move(position)
signal on_exit_button_press()

func _ready():
	pass

func _on_touchscreen_input_joystick(position):
	emit_signal("on_joystick_move",position)

func _on_exit_button_pressed():
	emit_signal("on_exit_button_press")
