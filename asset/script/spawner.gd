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

func spawn():
	var spawn_unit = preload("res://asset/schene/unit.tscn").instance()
	spawn_unit.position = $".."/player_unit.position
	spawn_unit.attack_damage = attack_damage
	spawn_unit.hit_point = hit_point
	spawn_unit.max_hit_point = max_hit_point
	spawn_unit.texture = texture
	spawn_unit.side = side
	add_child(spawn_unit)
 
