extends Spatial

func _ready():
	$Area1.connect("body_entered", self, "on_body_entered", [1])
	$Area2.connect("body_entered", self, "on_body_entered", [2])
	$Area3.connect("body_entered", self, "on_body_entered", [3])

func on_body_entered(body, id):
	if body.name == "Player":
		print(id)
