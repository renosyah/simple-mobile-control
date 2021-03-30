extends Control

onready var rng = RandomNumberGenerator.new()

export(String) var entity_resources_path = "res://asset/schene/unit.tscn"
export(int) var max_child = 5
export(String) var side
export(Texture) var unit_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn():
	rng.randomize()
	var pos = Vector2(rng.randf_range(-600, 600),rng.randf_range(-600, 600))
	var spawn_entity = load(entity_resources_path).instance()
	spawn_entity.position = pos
	spawn_entity.texture = unit_sprite
	spawn_entity.side = side
	add_child(spawn_entity)


func _on_timer_timeout():
	if get_children().size() < (max_child + 1):
		spawn()

