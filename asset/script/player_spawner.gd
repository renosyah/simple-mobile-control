extends Control

onready var rng = RandomNumberGenerator.new()
onready var panel_died = $".."/canvas/panel_died

export(NodePath) var camera_node

# Called when the node enters the scene tree for the first time.
func _ready():
	panel_died.visible = false
	$timer.wait_time = 5
	$timer.start()
	pass # Replace with function body.

func spawn():
	rng.randomize()
	var spawn_entity = preload("res://asset/schene/player.tscn").instance()
	spawn_entity.position = Vector2(rng.randf_range(-300, 300),rng.randf_range(-300, 300))
	spawn_entity.camera_node = NodePath("../" + str(camera_node))
	spawn_entity.connect("on_unit_died",self,"_on_unit_died")
	add_child(spawn_entity)
	$timer.stop()


func _on_timer_timeout():
	panel_died.visible = false
	spawn()

func _on_unit_died(node):
	panel_died.visible = true
	remove_child(node)
	$timer.wait_time = 5
	$timer.start()
