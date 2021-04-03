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
	Network.create_server(31400,_player_name,_player_sprite_path)
	_load_game()


func _on_button_find_server_pressed():
	if _player_name == "" and _player_sprite_path == "":
		return
	Network.connect_to_server("10.42.0.1", 31400, _player_name,_player_sprite_path)
	_load_game()
