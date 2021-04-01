extends KinematicBody2D

# const
const MAX_STAMINA = 100.0
const MAX_HIT_POINT = 100.0
const killed_sound = [
		preload("res://asset/sound/maledeath3.wav"),
		preload("res://asset/sound/maledeath4.wav")

]
const combats_sound = [
	preload("res://asset/sound/stab1.wav"),
	preload("res://asset/sound/stab2.wav"),
	preload("res://asset/sound/stab3.wav")
]
const target_sprite_range = preload("res://asset/sprite/target.png")
const target_sprite_melee = preload("res://asset/sprite/target_sword.png")

enum {
	MOVE,
	ATTACK
}

 # signal
signal hit_point_change(hp)
signal stamina_point_change(stamina)
signal on_unit_died()

# mutable variable
var joystick_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var targets: = []
var range_targets: = []
var state = MOVE

# onready variable
onready var rng = RandomNumberGenerator.new()
onready var sprite = $sprite
onready var animation = $animation
onready var animation_tree = $animation_tree
onready var animation_state = animation_tree.get("parameters/playback")
onready var audio = $audio

# public variable
export var attack_damage: = 15.0
export var hit_point: = 100.0 setget _set_hit_point
export var stamina_point: = 100.0 setget _set_stamina_point
export var max_speed: = 250
export var friction : = 500
export var side = "1"
export var texture: Texture


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
			

#########################################################
# unit move state and animation
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



#########################################################
# unit attack state and animation
func attack(_delta):
	animation_state.travel("character_attack")

func _on_attack_animation_end():
	state = MOVE


#########################################################
# unit input control from user
func _on_touch_input_on_joystick_move(position):
	joystick_velocity = position
	
func _on_touch_input_on_attack_button_press():
	if self.stamina_point <= 0.0 || targets.size() == 0:
		return
	state = ATTACK
	for target in targets:
		self.stamina_point -= 10
		target.take_damage(attack_damage)
	play_hit_sound()
	
func _input(event):
	if event.is_action_pressed("attack"):
		_on_touch_input_on_attack_button_press()
		
func _on_touch_input_on_throw_button_press():
	if self.stamina_point <= 0.0 || range_targets.size() == 0:
		return
	for range_target in range_targets:
		self.stamina_point -= 20
		var direction = (range_target.global_position - global_position).normalized()
		shoot_spear(direction)


#########################################################
# spawn spear
func shoot_spear(dir):
	var spear = preload("res://asset/schene/arrow.tscn").instance()
	spear.attack_damage = attack_damage / 2
	spear.lauching(global_position, dir)
	add_child(spear)


#########################################################
# unit hit and dead sound
func play_dead_sound():
	audio.stream = killed_sound[rng.randf_range(0,killed_sound.size())]
	audio.connect("finished",self,"_on_dead_sound_end")
	audio.play()
	
func _on_dead_sound_end():
	audio.disconnect("finished",self,"_on_dead_sound_end")
	set_physics_process(false)
	animation_state.travel("character_dead")
	
func play_hit_sound():
	audio.stream = combats_sound[rng.randf_range(0,combats_sound.size())]
	audio.play()


#########################################################
# unit hit dead sanimation end
func _on_dead_animation_end():
	emit_signal("on_unit_died")
	queue_free()
	

#########################################################
# unit hit point
func take_damage(damage):
	self.hit_point -= damage
	if self.hit_point <= 0.0:
		play_dead_sound()
		
func _set_hit_point(hp):
	hit_point = max(0, hp)
	emit_signal("hit_point_change",hit_point)

#########################################################
# unit stamina point
func _set_stamina_point(sp):
	stamina_point = max(0, sp)
	emit_signal("stamina_point_change", stamina_point)
	

func _on_stamina_regeneration_time_timeout():
	if self.stamina_point < MAX_STAMINA:
		self.stamina_point += 5.0

#########################################################
# on enemy enter attack area of player unit
func _on_attack_area_body_entered(_body):
	if _body is KinematicBody2D and _body.side != side:
		targets.append(_body)
		for target in targets:
			target.targeting_sprite.visible = true
			target.targeting_sprite.texture = target_sprite_melee

# on enemy exit attack area of player unit
func _on_attack_area_body_exited(_body):
	if _body is KinematicBody2D and _body.side != side:
		_body.targeting_sprite.visible = false
	targets.erase(_body)


func _on_attack_range_area_body_entered(_body):
	if _body is KinematicBody2D and _body.side != side:
		range_targets.append(_body)
		for range_target in range_targets:
			range_target.targeting_sprite.visible = true
			range_target.targeting_sprite.texture = target_sprite_range

func _on_attack_range_area_body_exited(_body):
	if _body is KinematicBody2D and _body.side != side:
		_body.targeting_sprite.visible = false
	range_targets.erase(_body)

