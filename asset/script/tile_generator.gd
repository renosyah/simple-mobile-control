extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_tile_map()

func generate_tile_map():
	var grass = get_tileset().find_tile_by_name("grass.png 0")
	var rng = RandomNumberGenerator.new()

	for x in range(-25,25):
		for y in range(-25,25):
			rng.randomize()
			var id = int(rng.randf_range(1, 3))
			var stone = get_tileset().find_tile_by_name("stone.png " + str(id))
			set_cell(x, y, stone)
			
	for x in range(-15,15):
		for y in range(-15,15):
			set_cell(x, y, grass)
			
	for x in range(-5, 5):
		for y in range(-5, 5):
			rng.randomize()
			var id = int(rng.randf_range(4, 6))
			var road = get_tileset().find_tile_by_name("stone.png " + str(id))
			set_cell(x, y, road)
