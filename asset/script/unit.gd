extends KinematicBody2D

onready var rng = RandomNumberGenerator.new()
onready var detection_area = $detection_area
onready var sprite = $sprite
onready var attact_delay = $attack_delay

export var damage: = 15.0
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

var target: KinematicBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = texture
	attact_delay.wait_time = attack_delay_value
	set_physics_process(false)

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(target.global_position)
		sprite.flip_h = direction.x < 0
	
		if distance_to_target >= min_to_attack_distance and distance_to_target < max_to_attack_distance:
			$animation.play("character_walking")
			move_and_collide(direction * max_speed * delta)

		if attact_delay.is_stopped() and distance_to_target <= attack_distance:
			$animation.play("character_attack")
			rng.randomize()
			target.take_damage(rng.randf_range(damage/2, damage))
			attact_delay.start()
	else:
		$animation.play("character_idle")

func _on_detection_area_body_entered(body):
	if body is KinematicBody2D and body.side != side:
		target = body
		set_physics_process(true)
	
func take_damage(damage):
	self.hit_point -= damage
	if self.hit_point <= 0:
		set_physics_process(false)
		queue_free()

func _set_hit_point(hp):
	hit_point = max(0,hp)
	$hit_point.value = hit_point

func _on_detection_area_body_exited(body):
	var distance_to_target = global_position.distance_to(body.global_position)
	if distance_to_target < min_to_attack_distance:
		target = null
		$animation.play("character_idle")
		set_physics_process(false)

func _on_timer_reset_target_timeout():
	detection_area.monitoring = false
	detection_area.monitoring = true
