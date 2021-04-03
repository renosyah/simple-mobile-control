extends Button


export(String) var sprite_path
export(bool) var is_choosed


# Called when the node enters the scene tree for the first time.
func _ready():
	icon = load(sprite_path)
	flat = !is_choosed


