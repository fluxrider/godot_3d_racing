extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().find_node("Checkpoints").connect("lap", self, "on_lap")
	$Timer.connect("timeout", self, "on_timer")

func on_lap(user, lap, time):
	self.text = "Lap " + str(lap) + ": " + str(time) + "ms"
	$Timer.start()

func on_timer():
	self.text = ""
