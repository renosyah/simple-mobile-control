extends Node

# broadcast to outside schene signal
signal on_joystick_move(position)
signal on_attack_button_press()
signal on_exit_button_pressed()

func _ready():
	pass

func _on_touchscreen_input_joystick(position):
	emit_signal("on_joystick_move",position)

func _on_exit_button_pressed():
	emit_signal("on_exit_button_pressed")
	
func _exit_tree():
	free()

func _on_attack_button_pressed():
	emit_signal("on_attack_button_press")

func _on_player_unit_hit_point_change(hp):
	$v_container/h_top_ui/hit_point.value = hp

func _on_player_unit_enemy_in_range(is_attackable):
	$v_container/h_input_ui/right_input/attack_button.visible = is_attackable
