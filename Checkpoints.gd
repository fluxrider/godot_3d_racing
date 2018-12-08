extends Spatial

var lap = 0
var prev = 3
var checkpoints = []

func _ready():
	$Area1.connect("body_entered", self, "on_body_entered", [1])
	$Area2.connect("body_entered", self, "on_body_entered", [2])
	$Area3.connect("body_entered", self, "on_body_entered", [3])

func on_body_entered(body, id):
	if body.name == "Player":
		if id == 1:
			if prev == 3 and (lap == 0 or checkpoints == [1,2,3]):
				lap += 1
				checkpoints = [1]
				print("lap: " + str(lap))
		else:
			if checkpoints.size() > 0 and checkpoints[-1] == id - 1 and prev == id - 1:
				checkpoints.append(id)
		prev = id
		print("checkpoint: " + str(id))
		print("history: " + str(checkpoints))
