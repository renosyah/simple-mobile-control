extends Node

onready var rng = RandomNumberGenerator.new()

export(String) var entity_resources_path = "res://asset/schene/unit.tscn"
export(int) var max_child = 5
export(String) var side = "bandit"
export(Texture) var unit_sprite = preload("res://asset/sprite/red_knight.png")

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var info = Network.self_data

	var new_player = preload("res://asset/schene/player.tscn").instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	new_player.camera_node = NodePath("../main_camera")
	
	# stats for player unit
	new_player.position = info.position
	new_player.player_name = info.name
	new_player.attack_damage = 15.0
	new_player.max_target = 1
	new_player.hit_point = 100.0
	new_player.max_hit_point = 100.0
	new_player.stamina_point = 100.0
	new_player.max_stamina_point = 100.0
	new_player.side = info.side
	new_player.is_slave = false
	new_player.side = "player"
	new_player.texture = load(info.sprite_path)
	
	add_child(new_player)


func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://asset/schene/menu.tscn')

func spawn_ai():
	rng.randomize()
	var spawn_entity = load(entity_resources_path).instance()
	spawn_entity.position = Vector2(rng.randf_range(-500, 500),rng.randf_range(-500, 500))
	spawn_entity.texture = unit_sprite
	spawn_entity.side = side
	add_child(spawn_entity)


func _on_enemy_spawn_delay_timeout():
	spawn_ai()
