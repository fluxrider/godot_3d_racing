extends Spatial

signal lap

var laps = {} # per users

func _ready():
	$Area1.connect("body_entered", self, "on_body_entered", [1])
	$Area2.connect("body_entered", self, "on_body_entered", [2])
	$Area3.connect("body_entered", self, "on_body_entered", [3])
	self.connect("lap", self, "on_lap")

func on_lap(user, lap):
	print(str(user) + " is on lap " + str(lap))

func on_body_entered(body, id):
	var user = body.name
	if user.begins_with("Player"):
		# init per user struct
		if not user in laps:
			laps[user] = {
				lap = 0,
				prev = 3,
				checkpoint = 0
			}
		# update lap data for this user
		var info = laps[user]
		if id == 1:
			if info.prev == 3 and (info.lap == 0 or info.checkpoint == 3):
				info.lap += 1
				info.checkpoint = 1
				emit_signal("lap", user, info.lap)
		else:
			if info.checkpoint == id - 1 and info.prev == id - 1:
				info.checkpoint = id
		info.prev = id