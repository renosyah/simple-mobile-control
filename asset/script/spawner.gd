extends Control

export(float) var attack_damage = 15.0
export var hit_point: = 100.0
export var max_hit_point: = 100.0
export(int) var max_unit = 5
export(String) var side = "rebel"
export(Texture) var texture = preload("res://asset/sprite/blue_knight.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

remotesync func spawn(pos):
	var spawn_unit = preload("res://asset/schene/unit.tscn").instance()
	spawn_unit.name = "pion_" + str(get_tree().get_network_unique_id())
	spawn_unit.set_network_master(get_tree().get_network_unique_id())
	spawn_unit.position = pos
	spawn_unit.attack_damage = attack_damage
	spawn_unit.hit_point = hit_point
	spawn_unit.max_hit_point = max_hit_point
	spawn_unit.texture = texture
	spawn_unit.side = side
	add_child(spawn_unit)
 

func _on_touch_input_on_spawn_button_press():
	if get_children().size() < (max_unit + 1):
		rpc("spawn",$".."/player_unit.position)
