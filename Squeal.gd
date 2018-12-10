extends "ProceduralPlayer.gd"

func _physics_process(delta):
	var player = get_parent().find_node("Player")
	if player.squealing:
		self.set_hz(120 - player.acceleration.length() + OS.get_ticks_msec() % 10)
	else:
		self.set_hz(0)

func gen_buffer(n):
	# saw-thooth wave
	var audio_buffer = PoolByteArray()
	for i in range(0, n * 2):
		audio_buffer.append(int(i * 254 / n) - 127)

	# update player
	sample.loop_end = n * 2
	sample.data = audio_buffer