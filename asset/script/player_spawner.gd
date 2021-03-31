extends Control

onready var panel_died = get_node(NodePath("../main_camera/panel_died"))
export(NodePath) var camera_node

# Called when the node enters the scene tree for the first time.
func _ready():
	panel_died.visible = false
	pass # Replace with function body.

func spawn():
	var spawn_entity = preload("res://asset/schene/player.tscn").instance()
	spawn_entity.camera_node = NodePath("../" + str(camera_node))
	spawn_entity.connect("on_unit_died",self,"_on_unit_died")
	add_child(spawn_entity)


func _on_timer_timeout():
	panel_died.visible = false
	if get_children().size() < 2:
		spawn()

func _on_unit_died(node):
	panel_died.visible = true
	remove_child(node)
