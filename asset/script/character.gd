extends KinematicBody2D

const MOTION_SPEED = 500
const TAN30DEG = tan(deg2rad(30))

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var motion = Vector2()
	motion.x = velocity.x
	motion.y = velocity.y
	motion.y *= TAN30DEG
	motion = motion.normalized() * MOTION_SPEED
	
	if motion.x == 0.0 || motion.y ==  0.0:
		$animation.play("idle")
	else:
		$animation.play("walking")
	
	move_and_slide(motion)

func _on_touch_input_on_joystick_move(position):
	velocity = position

