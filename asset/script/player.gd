extends Control

signal on_unit_died(node)

onready var remote_transform = RemoteTransform2D.new()

export(Vector2) var position
export(NodePath) var camera_node

# public variable
export(String) var player_name = ""
export(float) var attack_damage
export(float) var hit_point
export(float) var max_hit_point
export(float) var stamina_point
export(float) var max_stamina_point
export(int) var max_target
export(String) var side

export(bool) var is_slave = false

# Called when the node enters the scene tree for the first time.
func _ready():
	remote_transform.remote_path = NodePath("../../" + str(camera_node))
	remote_transform.force_update_cache()
	$player_unit.add_child(remote_transform)
	$player_unit.player_name = player_name
	$player_unit.position = position
	$player_unit.attack_damage = attack_damage
	$player_unit.max_target = max_target
	$player_unit.hit_point = hit_point
	$player_unit.max_hit_point = max_hit_point
	$player_unit.stamina_point = stamina_point
	$player_unit.max_stamina_point = max_stamina_point
	$player_unit.side = side
	$player_unit.is_slave = is_slave
	$player_unit.update_status_bar()
	if is_slave:
		remove_child($canvas)

func _on_touch_input_on_exit_button_pressed():
	get_tree().quit(0)

func _on_player_unit_on_unit_died():
	emit_signal("on_unit_died", self)
