extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var save_game = load("res://asset/script/save_game.gd").new()

var _player_name = ""
var random_name = load("res://asset/script/random_names.gd")
onready var button_choose_name = $canvas/VBoxContainer/HBoxContainer/character_name_chooser

var list_server = []
onready var server_list_panel = $canvas/panel_list_server
onready var server_list_container = $canvas/panel_list_server/VBoxContainer/VScrollBar/VBoxContainer

var _player_sprite_path = "res://asset/sprite/blue_knight.png"
var sprite_options = [
	"res://asset/sprite/blue_knight.png",
	"res://asset/sprite/red_knight.png",
	"res://asset/sprite/green_knight.png",
	"res://asset/sprite/purple_knight.png",
	"res://asset/sprite/white_knight.png"
]
onready var panel_list_sprite_chooser = $canvas/panel_list_sprite_chooser
onready var panel_list_sprite_container = $canvas/panel_list_sprite_chooser/VBoxContainer/VScrollBar/GridContainer
onready var character_sprite_chooser = $canvas/VBoxContainer/character_sprite_chooser


# Called when the node enters the scene tree for the first time.
func _ready():
	ready_sprite_chooser()
	var load_file = save_game.loadGame()
	if load_file != null:
		_player_name = load_file["player_name"]
		_player_sprite_path = load_file["player_sprite_path"]
		button_choose_name.text = _player_name
		character_sprite_chooser.icon = load(_player_sprite_path)

func save():
	var save_file = {
		"player_name":_player_name,
		"player_sprite_path":_player_sprite_path
	}
	save_game.saveGame(save_file)



func _on_random_name_button_pressed():
	var names = random_name.new()
	_player_name = names.generate()
	button_choose_name.text = _player_name

func ready_sprite_chooser():
	for child in panel_list_sprite_container.get_children():
		panel_list_sprite_container.remove_child(child)
		
	for sprite_option in sprite_options:
		var item = preload("res://asset/schene/item_color.tscn").instance()
		item.sprite_path = sprite_option
		item.is_choosed = (sprite_option == _player_sprite_path)
		item.connect("pressed", self, "_on_panel_list_sprite_item_choose",[sprite_option])
		panel_list_sprite_container.add_child(item)

func _on_panel_list_sprite_item_choose(choosed_sprite):
	_player_sprite_path = choosed_sprite
	character_sprite_chooser.icon = load(_player_sprite_path)
	_on_sprite_chooser_close_button_pressed()
	ready_sprite_chooser()

func _load_game():
	get_tree().change_scene("res://asset/schene/main.tscn")

func _on_button_single_player_pressed():
	if _player_name == "" and _player_sprite_path == "":
		return
	save()
	Network.create_server(Network.DEFAULT_PORT,_player_name,_player_sprite_path)
	get_tree().change_scene("res://asset/schene/main_single.tscn")
	
func _on_button_create_server_pressed():
	if _player_name == "" and _player_sprite_path == "":
		return
	save()
	Network.create_server(Network.DEFAULT_PORT,_player_name,_player_sprite_path)
	_load_game()

func _on_button_find_server_pressed():
	server_list_panel.visible = true

func _on_server_list_close_button_pressed():
	server_list_panel.visible = false

func _on_sprite_chooser_button_pressed():
	panel_list_sprite_chooser.visible = true

func _on_sprite_chooser_close_button_pressed():
	panel_list_sprite_chooser.visible = false
		
func _on_ServerListener_new_server(serverInfo):
	if serverInfo["public"]:
		list_server.append(serverInfo)
		show_list_item_server()

func show_list_item_server():
	for child in server_list_container.get_children():
		child.disconnect("pressed",self,"_connect_to_server")
		server_list_container.remove_child(child)
		
	for s in list_server:
		var button = preload("res://asset/schene/item_server.tscn").instance()
		button.init_item(s)
		button.connect("pressed",self,"_connect_to_server",[s])
		server_list_container.add_child(button)

func _on_ServerListener_remove_server(ip):
	var info = {}
	for s in list_server:
		if s.ip == ip:
			info = s
			break
	list_server.erase(info)
	show_list_item_server()
	
func _connect_to_server(serverInfo):
	if _player_name == "" and _player_sprite_path == "":
		return
	save()
	Network.connect_to_server(serverInfo.ip,serverInfo.port,_player_name,_player_sprite_path)
	_load_game()
