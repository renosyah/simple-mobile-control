extends Control

onready var rng = RandomNumberGenerator.new()

export(float) var attack_damage = 15.0
export(int) var max_child = 5
export(String) var side = "rebel"
export(String) var unit_sprite_path = "res://asset/sprite/knight_white.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


sync func spawn():
	rng.randomize()
	var spawn_unit = preload("res://asset/schene/unit.tscn").instance()
	spawn_unit.position = Vector2(rng.randf_range(-500, 500),rng.randf_range(-500, 500))
	spawn_unit.attack_damage = attack_damage
	spawn_unit.texture = load(unit_sprite_path)
	spawn_unit.side = side
	add_child(spawn_unit)


func _on_timer_timeout():
	if get_children().size() < (max_child + 1):
		rpc("spawn")

