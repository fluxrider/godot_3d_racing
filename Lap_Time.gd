extends Label

func _ready():
	get_parent().find_node("Checkpoints").connect("lap", self, "on_lap")
	$Timer.connect("timeout", self, "on_timer")

func on_lap(user, lap, time):
	self.text = "Lap " + str(lap) + ": " + str(time) + "ms"
	$Timer.start()

func on_timer():
	self.text = ""
