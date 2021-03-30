extends Control

 
export var damage: = 15.0
export var acceleration: = 500
export var max_speed: = 350
export var friction : = 500
export var attack_distance: = 100.0 #80.0
export var min_to_attack_distance: = 100.0 #100.0
export var max_to_attack_distance: = 400.0
export var attack_delay_value: = 1.0
export var side = "player"
export var texture: Texture
export var position : = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	$camera.current = true

func _on_touch_input_on_exit_button_pressed():
	get_tree().quit(0)

