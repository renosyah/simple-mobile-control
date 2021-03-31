extends KinematicBody2D

signal hit_point_change(hp)
signal stamina_point_change(stamina)
signal on_unit_died()

const MAX_STAMINA = 100.0
var joystick_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var targets: = []

onready var rng = RandomNumberGenerator.new()
onready var sprite = $sprite
onready var animation = $animation
onready var animation_tree = $animation_tree
onready var animation_state = animation_tree.get("parameters/playback")
onready var audio = $audio

export var attack_damage: = 15.0
export var hit_point: = 100.0 setget _set_hit_point
export var stamina_point: = 100.0 setget _set_stamina_point
export var acceleration: = 500
export var max_speed: = 350
export var friction : = 500
export var side = "1"
export var texture: Texture

var state = MOVE
enum {
	MOVE,
	ATTACK
}

var killed_sound = [
		preload("res://asset/sound/maledeath3.wav"),
		preload("res://asset/sound/maledeath4.wav")

]
var combats_sound = [
	preload("res://asset/sound/stab1.wav"),
	preload("res://asset/sound/stab2.wav"),
	preload("res://asset/sound/stab3.wav")
]


# Called when the node enters the scene tree for the first time.
func _ready():
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
	if self.stamina_point <= 0.0 || targets.size() == 0:
		return
	audio.stream = combats_sound[rng.randf_range(0,combats_sound.size())]
	audio.play()
	state = ATTACK
	for target in targets:
		self.stamina_point -= 10
		target.take_damage(rng.randf_range(attack_damage/2,attack_damage))


func take_damage(damage):
	self.hit_point -= damage
	if self.hit_point <= 0.0:
		emit_signal("on_unit_died")
		audio.stream = killed_sound[rng.randf_range(0,killed_sound.size())]
		audio.connect("finished",self,"_on_dead_sound_end")
		audio.play()
		
func _on_dead_sound_end():
	audio.disconnect("finished",self,"_on_dead_sound_end")
	set_physics_process(false)
	queue_free()
	
func _set_hit_point(hp):
	hit_point = max(0, hp)
	emit_signal("hit_point_change",hit_point)
	

func _set_stamina_point(sp):
	stamina_point = max(0, sp)
	emit_signal("stamina_point_change", stamina_point)
	

func _on_attack_area_body_entered(_body):
	if _body is KinematicBody2D and _body.side != side:
		targets.append(_body)
		for target in targets:
			target.targeting_sprite.visible = true

func _on_attack_area_body_exited(_body):
	if _body is KinematicBody2D and _body.side != side:
		_body.targeting_sprite.visible = false
	targets.erase(_body)


func _on_stamina_regeneration_time_timeout():
	if self.stamina_point < MAX_STAMINA:
		self.stamina_point += 5.0
