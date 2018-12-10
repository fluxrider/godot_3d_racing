extends "res://ProceduralPlayer.gd"

func _physics_process(delta):
	var player = get_parent().find_node("Player")
	self.set_hz(6 + player.acceleration.length() * 2)