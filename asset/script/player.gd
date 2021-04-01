extends Control

signal on_unit_died(node)

onready var remote_transform = RemoteTransform2D.new()

export(Vector2) var position
export(NodePath) var camera_node

# Called when the node enters the scene tree for the first time.
func _ready():
	remote_transform.remote_path = NodePath("../../" + str(camera_node))
	remote_transform.force_update_cache()
	$player_unit.add_child(remote_transform)
	$player_unit.position = position

func _on_touch_input_on_exit_button_pressed():
	get_tree().quit(0)

func _on_player_unit_on_unit_died():
	emit_signal("on_unit_died", self)
