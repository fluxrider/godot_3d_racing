extends AudioStreamPlayer

var sample
var samples_per_second
var current_n = 0

func _ready():
	samples_per_second = 8000 # AudioServer.get_mix_rate()
	sample = AudioStreamSample.new()
	sample.format = AudioStreamSample.FORMAT_8_BITS
	sample.loop_mode = AudioStreamSample.LOOP_FORWARD
	sample.loop_begin = 0
	sample.loop_end = 0
	sample.mix_rate = samples_per_second
	sample.stereo = false
	self.volume_db = -13.0 # don't blast your ears!
	self.stream = sample # set the sample as source

func set_hz(hz):
	var n = int((samples_per_second / hz) / 2)
	if n == current_n: return
	current_n = n

	# generate data
	var audio_buffer = PoolByteArray()
	for i in range(0, n):
		audio_buffer.append(127)
	for i in range(0, n):
		audio_buffer.append(-127)

	sample.loop_end = n * 2
	sample.data = audio_buffer
	# changing the loop_end/data sometimes stops the player, so we need to kickstart it
	if not self.playing:
		self.play()
