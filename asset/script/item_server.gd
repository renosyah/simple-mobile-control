extends Button

export(String) var ip = ""
export(String) var server_device = ""
export(String) var host_name = ""
export(int) var port = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init_item(info):
	ip = info.ip
	server_device = info.server_device
	host_name = info.host_name
	port = info.port
	text = host_name + " on " + server_device + " (" + str(port) + ")"
