extends KinematicBody2D

# const
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
signal on_unit_ready(status_bar_data)
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
onready var targeting_sprite = $targeting_sprite
onready var animation = $animation
onready var animation_tree = $animation_tree
onready var animation_state = animation_tree.get("parameters/playback")
onready var audio = $audio

# public variable
export var attack_damage: = 15.0
export var hit_point: = 100.0 setget _set_hit_point
export var max_hit_point: = 100.0
export var stamina_point: = 100.0 setget _set_stamina_point
export var max_stamina_point: = 100.0
export var max_speed: = 250
export var friction : = 500
export var max_target: = 1
export var side = "1"
export var texture: Texture

# slave
slave var slave_position = Vector2.ZERO
slave var slave_movement = Vector2.ZERO
slave var slave_state = MOVE

func init(nickname, start_position, is_slave):
	position = start_position
	if is_slave:
		sprite.texture = preload("res://asset/sprite/red_knight.png")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		MOVE:
			move_unit(_delta)
		ATTACK:
			attack(_delta)

#########################################################
# unit move state and animation
func update_status_bar():
	emit_signal("on_unit_ready",{ 
		"hit_point" : hit_point,
		"max_hit_point" : max_hit_point,
		"stamina_point" : stamina_point,
		"max_stamina_point" : max_stamina_point
	})

#########################################################
# unit move state and animation
func move_unit(_delta):
	if is_network_master():
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
		
		move_and_slide(velocity)
		
		rset_unreliable('slave_position', position)
		rset('slave_movement', velocity)
		
	else:
		position = slave_position
		if slave_movement != Vector2.ZERO:
			animation_state.travel("character_walking")
		else:
			animation_state.travel("character_idle")

		move_and_collide(velocity)
		
		
	if get_tree().is_network_server():
		Network.update_position(int(get_parent().name), position)

#########################################################
# unit attack state and animation
func attack(_delta):
	animation_state.travel("character_attack")

func _on_attack_animation_end():
	state = MOVE


#########################################################
# unit hit animation functions
func dead():
	animation_state.travel("character_dead")

func _on_dead_animation_end():
	emit_signal("on_unit_died")
	queue_free()
	

#########################################################
# unit input control from user
func _on_touch_input_on_joystick_move(position):
	joystick_velocity = position
	
func _on_touch_input_on_attack_button_press():
	if is_network_master():
		rpc("_swing_sword")
	
func _input(event):
	if is_network_master():
		if event.is_action_pressed("attack"):
			rpc("_throw_spear")
		elif event.is_action_pressed("throw_spear"):
			rpc("_swing_sword")
		
func _on_touch_input_on_throw_button_press():
	if is_network_master():
		rpc("_throw_spear")
	
#########################################################
# spawn spear for range attack 
sync func _throw_spear():
	var required_stamina = attack_damage
	if self.stamina_point - required_stamina <= 0.0 || range_targets.size() == 0:
		return
	for range_target in range_targets:
		self.stamina_point -= required_stamina
		var direction = (range_target.global_position - global_position).normalized()
		var spear = preload("res://asset/schene/arrow.tscn").instance()
		spear.attack_damage = attack_damage / 2
		spear.lauching(global_position, direction)
		add_child(spear)
	
# slash with sword for close attack
sync func _swing_sword():
	var required_stamina = attack_damage
	if self.stamina_point - required_stamina <= 0.0 || targets.size() == 0:
		return
	state = ATTACK
	for target in targets:
		self.stamina_point -= required_stamina
		target.take_damage(attack_damage)
	play_hit_sound()

#########################################################
# unit hit sound functions
func play_dead_sound():
	audio.stream = killed_sound[rng.randf_range(0,killed_sound.size())]
	audio.connect("finished",self,"_on_dead_sound_end")
	audio.play()
	
func _on_dead_sound_end():
	audio.disconnect("finished",self,"_on_dead_sound_end")
	set_physics_process(false)
	dead()
	
func play_hit_sound():
	audio.stream = combats_sound[rng.randf_range(0,combats_sound.size())]
	audio.play()


#########################################################
# unit hit point and stamina functions
func take_damage(damage):
	self.hit_point -= damage
	if self.hit_point <= 0.0:
		play_dead_sound()
		
func _set_hit_point(hp):
	hit_point = max(0, hp)
	emit_signal("hit_point_change",hit_point)


func _set_stamina_point(sp):
	stamina_point = max(0, sp)
	emit_signal("stamina_point_change", stamina_point)
	

func _on_stamina_regeneration_time_timeout():
	if self.stamina_point < max_stamina_point:
		self.stamina_point += (max_stamina_point * 10.0) / 100.0

#########################################################
# on enemy enter attack area of player unit
func _on_attack_area_body_entered(_body):
	if _body is KinematicBody2D and _body.side != side:
		if targets.size() >= max_target:
			return
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
		if range_targets.size() >= max_target:
			return
		range_targets.append(_body)
		for range_target in range_targets:
			range_target.targeting_sprite.visible = true
			range_target.targeting_sprite.texture = target_sprite_range

func _on_attack_range_area_body_exited(_body):
	if _body is KinematicBody2D and _body.side != side:
		_body.targeting_sprite.visible = false
	range_targets.erase(_body)

