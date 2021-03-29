extends KinematicBody2D

onready var detection_area = $detection_area
onready var sprite = $sprite
onready var attact_delay = $attack_delay

export var damage: = 76.0
export var move_speed: = 350
export var attack_distance: = 100.0 #80.0
export var min_to_attack_distance: = 80.0 #100.0
export var max_to_attack_distance: = 400.0

onready var rng = RandomNumberGenerator.new()

var target: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	$animation.play("character_idle")
	set_physics_process(false)
	detection_area.connect("body_entered",self,"_on_detection_area_body_entered")

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(target.global_position)
		sprite.flip_h = direction.x < 0
	
		if distance_to_target >= min_to_attack_distance and distance_to_target < max_to_attack_distance:
			$animation.play("character_walking")
			move_and_collide(direction * move_speed * delta)

		else:
			$animation.play("character_idle")
			
		if attact_delay.is_stopped() and distance_to_target <= attack_distance:
			rng.randomize()
			target.take_damage(rng.randf_range(45.0, damage))
			attact_delay.start()
			
	else:
		$animation.play("character_idle")

func _on_detection_area_body_entered(body):
	if not body is Player:
		return
	target = body
	set_physics_process(true)
	detection_area.disconnect("body_entered",self,"_on_detection_area_body_entered")
