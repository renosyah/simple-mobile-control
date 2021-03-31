extends KinematicBody2D


onready var rng = RandomNumberGenerator.new()
onready var detection_area = $detection_area
onready var sprite = $sprite
onready var attack_delay = $attack_delay
onready var targeting_sprite = $targeting_sprite
onready var audio = $audio

onready var animation = $animation
onready var animation_tree = $animation_tree
onready var animation_state = animation_tree.get("parameters/playback")

export var attack_damage: = 15.0
export var hit_point: = 100.0 setget _set_hit_point
export var acceleration: = 500
export var max_speed: = 350
export var friction : = 500
export var attack_distance: = 100.0 #80.0
export var min_to_attack_distance: = 100.0 #100.0
export var max_to_attack_distance: = 400.0
export var attack_delay_value: = 1.0
export var side = "player"
export var texture: Texture

var killed_sound = [
		preload("res://asset/sound/maledeath3.wav"),
		preload("res://asset/sound/maledeath4.wav")

]
var combats_sound = [
	preload("res://asset/sound/stab1.wav"),
	preload("res://asset/sound/stab2.wav"),
	preload("res://asset/sound/stab3.wav")
]

var target: KinematicBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = texture
	attack_delay.wait_time = attack_delay_value
	set_physics_process(false)
	

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(target.global_position)
		sprite.flip_h = direction.x < 0
	
		if distance_to_target >= min_to_attack_distance and distance_to_target < max_to_attack_distance:
			animation_state.travel("character_walking")
			move_and_collide(direction * max_speed * delta)

		if attack_delay.is_stopped() and distance_to_target <= attack_distance:
			animation_state.travel("character_attack")
			rng.randomize()
			audio.stream = combats_sound[rng.randf_range(0,combats_sound.size())]
			audio.play()
			target.take_damage(rng.randf_range(attack_damage/2, attack_damage))
			attack_delay.start()
	else:
		animation_state.travel("character_idle")

func _on_detection_area_body_entered(body):
	if body is KinematicBody2D and body.side != side:
		target = body
		set_physics_process(true)
	
func take_damage(damage):
	rng.randomize()
	self.hit_point -= damage
	if self.hit_point <= 0:
		audio.stream = killed_sound[rng.randf_range(0,killed_sound.size())]
		audio.connect("finished",self,"_on_dead_sound_end")
		audio.play()

func _on_dead_sound_end():
	audio.disconnect("finished",self,"_on_dead_sound_end")
	set_physics_process(false)
	queue_free()

func _set_hit_point(hp):
	hit_point = max(0,hp)
	$hit_point.value = hit_point

func _on_detection_area_body_exited(_body):
	if _body is KinematicBody2D:
		var distance_to_target = global_position.distance_to(_body.global_position)
		if distance_to_target < min_to_attack_distance:
			target = null
			animation_state.travel("character_idle")
			set_physics_process(false)

func _on_timer_reset_target_timeout():
	detection_area.monitoring = false
	detection_area.monitoring = true
