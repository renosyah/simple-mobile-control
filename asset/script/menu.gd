extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _player_name = ""
var _player_sprite_path = ""

var sprite_options = [
	"res://asset/sprite/blue_knight.png",
	"res://asset/sprite/red_knight.png",
	"res://asset/sprite/green_knight.png",
	"res://asset/sprite/purple_knight.png",
	"res://asset/sprite/white_knight.png"
]

var list_server = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for b in sprite_options:
		var button = TextureButton.new()
		button.texture_normal = load(b)
		button.connect("pressed",self,"_button_color_press", [b])
		$canvas/v_menu/h_menu_input_color.add_child(button)

func _button_color_press(sprite_path):
	_player_sprite_path = sprite_path
	
	for child in $canvas/v_menu/h_menu_input_color.get_children():
		if child is TextureButton:
			child.disconnect("pressed",self,"_button_color_press")
			$canvas/v_menu/h_menu_input_color.remove_child(child)
		
	var button = TextureButton.new()
	button.texture_normal = load(sprite_path)
	$canvas/v_menu/h_menu_input_color.add_child(button)

func _load_game():
	get_tree().change_scene("res://asset/schene/main.tscn")


func _on_TextEdit_text_changed(new_text):
	_player_name = new_text


func _on_button_create_server_pressed():
	if _player_name == "" and _player_sprite_path == "":
		return
	Network.create_server(Network.DEFAULT_PORT,_player_name,_player_sprite_path)
	_load_game()


func _on_button_find_server_pressed():
	$canvas/dialog_list_server.show()
	
func _on_ServerListener_new_server(serverInfo):
	list_server.append(serverInfo)
	show_list_item_server()

func show_list_item_server():
	for child in $canvas/dialog_list_server/VScrollBar/VBoxContainer.get_children():
		child.disconnect("pressed",self,"_connect_to_server")
		$canvas/dialog_list_server/VScrollBar/VBoxContainer.remove_child(child)
		
	for s in list_server:
		var button = preload("res://asset/schene/item_server.tscn").instance()
		button.init_item(s)
		button.connect("pressed",self,"_connect_to_server",[s])
		$canvas/dialog_list_server/VScrollBar/VBoxContainer.add_child(button)

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
	Network.connect_to_server(serverInfo.ip,serverInfo.port,_player_name,_player_sprite_path)
	_load_game()


