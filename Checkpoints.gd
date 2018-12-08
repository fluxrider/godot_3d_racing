extends Spatial

var lap = 0
var prev = 3
var checkpoint = 0

func _ready():
	$Area1.connect("body_entered", self, "on_body_entered", [1])
	$Area2.connect("body_entered", self, "on_body_entered", [2])
	$Area3.connect("body_entered", self, "on_body_entered", [3])

func on_body_entered(body, id):
	if body.name == "Player":
		if id == 1:
			if prev == 3 and (lap == 0 or checkpoint == 3):
				lap += 1
				checkpoint = 1
				print("lap: " + str(lap))
		else:
			if checkpoint == id - 1 and prev == id - 1:
				checkpoint = id
		prev = id
		print("id: " + str(id))
		print("checkpoint: " + str(checkpoint))
