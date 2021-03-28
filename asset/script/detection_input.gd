extends Area2D

var all_visible = false

func _ready():
	pass
	
func _process(delta):
	$joystick.visible = all_visible
	
func _input(ev):
	get_viewport().unhandled_input(ev)
	
func _input_event(viewport, event, shape_idx):
	all_visible = event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed())
	if event is InputEventScreenTouch and event.is_pressed():
		$joystick.position = event.position

