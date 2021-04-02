extends Control

onready var rng = RandomNumberGenerator.new()
onready var panel_died = $".."/canvas/panel_died

export(NodePath) var camera_node


# Called when the node enters the scene tree for the first time.
func _ready():
	panel_died.visible = false
	$timer.wait_time = 1
	$timer.start()
	pass # Replace with function body.

func spawn():
	rng.randomize()
	var spawn_unit = preload("res://asset/schene/player.tscn").instance()
	spawn_unit.position = Vector2(rng.randf_range(-300, 300),rng.randf_range(-300, 300))
	spawn_unit.connect("on_unit_died",self,"_on_unit_died")
	spawn_unit.attack_damage = 15.0
	spawn_unit.max_target = 1
	spawn_unit.hit_point = 100.0
	spawn_unit.max_hit_point = 100.0
	spawn_unit.stamina_point = 100.0
	spawn_unit.max_stamina_point = 100.0
	add_child(spawn_unit)
	$timer.stop()


func _on_timer_timeout():
	panel_died.visible = false
	spawn()

func _on_unit_died(node):
	panel_died.visible = true
	remove_child(node)
	$timer.wait_time = 5
	$timer.start()
