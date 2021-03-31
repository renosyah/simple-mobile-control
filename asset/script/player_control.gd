extends KinematicBody2D

signal hit_point_change(hp)
signal on_unit_died()

var joystick_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var target: KinematicBody2D = null

onready var sprite = $sprite
onready var rng = RandomNumberGenerator.new()

export var attack_damage: = 15.0
export var hit_point: = 100.0 setget _set_hit_point
export var acceleration: = 500
export var max_speed: = 350
export var friction : = 500
export var side = "1"
export var texture: Texture


onready var animation = $animation
onready var animation_tree = $animation_tree
onready var animation_state = animation_tree.get("parameters/playback")
var state = MOVE
enum {
	MOVE,
	ATTACK
}

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(rng.randf_range(-600, 600),rng.randf_range(-600, 600))
	set_physics_process(true)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		MOVE:
			move(_delta)
		ATTACK:
			attack(_delta)


func move(_delta):
	var motion = Vector2.ZERO
	motion.x = joystick_velocity.x
	motion.y = joystick_velocity.y
	
	if joystick_velocity == Vector2.ZERO:
		motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		
	motion.normalized()
	
	if motion != Vector2.ZERO:
		animation_state.travel("character_walking")
		velocity = motion * max_speed
	else:
		animation_state.travel("character_idle")
		velocity = motion.move_toward(Vector2.ZERO * max_speed, friction * _delta)
	
	velocity = move_and_slide(velocity)

func attack(_delta):
	animation_state.travel("character_attack")

func on_attack_animation_end():
	state = MOVE

func _on_touch_input_on_joystick_move(position):
	joystick_velocity = position
	
func _on_touch_input_on_attack_button_press():
	state = ATTACK
	if is_instance_valid(target):
		target.take_damage(rng.randf_range(attack_damage/2,attack_damage))

func take_damage(damage):
	self.hit_point -= damage
	if self.hit_point <= 0:
		set_physics_process(false)
		emit_signal("on_unit_died")
		queue_free()

func _set_hit_point(hp):
	hit_point = max(0, hp)
	emit_signal("hit_point_change",hit_point)
	

func _on_attack_area_body_entered(_body):
	if _body is KinematicBody2D and _body.side != side:
		target = _body

func _on_attack_area_body_exited(_body):
	target = null
