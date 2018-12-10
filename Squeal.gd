extends "ProceduralPlayer.gd"

func gen_buffer(n):
	# saw-thooth wave
	var audio_buffer = PoolByteArray()
	for i in range(0, n * 2):
		audio_buffer.append(int(i * 254 / n) - 127)

	# update player
	sample.loop_end = n * 2
	sample.data = audio_buffer