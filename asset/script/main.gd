extends Node

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload("res://asset/schene/player.tscn").instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	new_player.camera_node = NodePath("../main_camera")
	new_player.attack_damage = 15.0
	new_player.max_target = 1
	new_player.hit_point = 100.0
	new_player.max_hit_point = 100.0
	new_player.stamina_point = 100.0
	new_player.max_stamina_point = 100.0
	new_player.side = str(new_player.name)
	add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://interface/Menu.tscn')

