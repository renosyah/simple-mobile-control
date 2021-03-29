extends Node

func _ready():
	generate_tile_map()
	
func generate_tile_map():
	var grass = $tile_map.get_tileset().find_tile_by_name("grass.png 0")
	var rng = RandomNumberGenerator.new()

	for x in range(-25,25):
		for y in range(-25,25):
			rng.randomize()
			var id = int(rng.randf_range(1, 3))
			var stone = $tile_map.get_tileset().find_tile_by_name("stone.png " + str(id))
			$tile_map.set_cell(x, y, stone)
			
	for x in range(-15,15):
		for y in range(-15,15):
			$tile_map.set_cell(x, y, grass)
			
	for x in range(-5, 5):
		for y in range(-5, 5):
			rng.randomize()
			var id = int(rng.randf_range(4, 6))
			var road = $tile_map.get_tileset().find_tile_by_name("stone.png " + str(id))
			$tile_map.set_cell(x, y, road)

func _on_touch_input_on_exit_button_press():
	queue_free()
	
func _exit_tree():
	free()
