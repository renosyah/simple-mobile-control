extends KinematicBody2D

class_name Player

signal hit_point_change(hp)

onready var sprite = $sprite

export var damage: = 5.0
export var hit_point: = 100.0 setget _set_hit_point
export var attack_distance: = 100.0 #80.0
export var min_to_attack_distance: = 80.0 #100.0
export var max_to_attack_distance: = 400.0

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
	
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	motion.y *= TAN30DEG
	motion = motion.normalized() * MOTION_SPEED
	
	sprite.flip_h = motion.x > 0.0

	if motion.x != 0.0 || motion.y !=  0.0:
		$animation.play("character_walking")
	else:
		$animation.play("character_idle")
	
	move_and_slide(motion)

func _on_touch_input_on_joystick_move(position):
	velocity = position
	
func take_damage(damage):
	self.hit_point -= damage
	if self.hit_point <= 0:
		queue_free()

func _set_hit_point(hp):
	hit_point = max(0,hp)
	emit_signal("hit_point_change",hit_point)
	

