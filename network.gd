extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const DEFAULT_ADVERTISE_PORT = 31401
const MAX_PLAYERS = 5

var rng = RandomNumberGenerator.new()
var players = { }
var self_data = { name = '', side = '', sprite_path = 'res://asset/sprite/knight_white.png', position = Vector2(360, 180) }

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func create_server(port :int = DEFAULT_PORT, player_nickname:String = "", sprite_path:String= 'res://asset/sprite/knight_white.png'):
	rng.randomize()
	self_data.name = player_nickname
	self_data.sprite_path = sprite_path
	self_data.position = Vector2(rng.randf_range(-400, 400),rng.randf_range(-400, 400))
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

func connect_to_server(ip:String = DEFAULT_IP,port :int = DEFAULT_PORT, player_nickname:String = "", sprite_path:String= 'res://asset/sprite/knight_white.png'):
	rng.randomize()
	self_data.name = player_nickname
	self_data.sprite_path = sprite_path
	self_data.position = Vector2(rng.randf_range(-400, 400),rng.randf_range(-400, 400))
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip,port)
	get_tree().set_network_peer(peer)

func disconnect_from_server():
	if is_instance_valid(get_tree().get_network_peer()):
		get_tree().get_network_peer().close_connection()

func _connected_to_server():
	var local_player_id = get_tree().get_network_unique_id()
	self_data.side = str(local_player_id)
	players[local_player_id] = self_data
	rpc('_send_player_info', local_player_id, self_data)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(connected_player_id):
	var local_player_id = get_tree().get_network_unique_id()
	if not(get_tree().is_network_server()):
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id)

remote func _request_player_info(request_from_id, player_id):
	if get_tree().is_network_server():
		rpc_id(request_from_id, '_send_player_info', player_id, players[player_id])


remote func _send_player_info(id, info):
	players[id] = info
	var new_player = load("res://asset/schene/player.tscn").instance()
	
	# stats stats for player slave unit
	new_player.name = str(id)
	new_player. position = info.position
	new_player.player_name = info.name
	new_player.attack_damage = 15.0
	new_player.max_target = 1
	new_player.hit_point = 100.0
	new_player.max_hit_point = 100.0
	new_player.stamina_point = 100.0
	new_player.max_stamina_point = 100.0
	new_player.side = info.side
	new_player.is_slave = true
	new_player.texture = load(info.sprite_path)
	
	new_player.set_network_master(id)
	$'/root/main/'.add_child(new_player)
	
func update_position(id, position):
	players[id].position = position
