extends KinematicBody2D

const MOTION_SPEED = 500
const TAN30DEG = tan(deg2rad(30))

var velocity = Vector2.ZERO
export(NodePath) var camera_node

# Called when the node enters the scene tree for the first time.
func _ready():
	set_remote_transform()
	
func set_remote_transform():
	$remote_transform.remote_path = NodePath("../" + str(camera_node))
	$remote_transform.force_update_cache()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var motion = Vector2()
	motion.x = velocity.x
	motion.y = velocity.y
	
	#motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	motion.y *= TAN30DEG
	motion = motion.normalized() * MOTION_SPEED
	
	if motion.x > 0.0:
		$sprite.scale.x = 1
	else:
		$sprite.scale.x = -1
	
	if motion.x != 0.0 || motion.y !=  0.0:
		$animation.play("walking")
	else:
		$animation.play("idle")
	
	move_and_slide(motion)

func _on_touch_input_on_joystick_move(position):
	velocity = position

