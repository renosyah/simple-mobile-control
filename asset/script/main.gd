extends Node

func _ready():
	pass

func _on_touch_input_on_exit_button_press():
	queue_free()
	
func _exit_tree():
	free()
