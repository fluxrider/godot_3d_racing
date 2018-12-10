extends AudioStreamPlayer

var hz = 6
var j = 0 # counter
var sample
var samples_per_second
var sample_length_factor = 1 # the shorter the better, but must be long enough for wanted frequency
var length

func _ready():
	#samples_per_second = AudioServer.get_mix_rate()
	samples_per_second = 8000
	#samples_per_second = 11025
	length = int(samples_per_second * sample_length_factor)
	sample = AudioStreamSample.new()
	sample.format = AudioStreamSample.FORMAT_8_BITS
	sample.loop_mode = AudioStreamSample.LOOP_FORWARD
	sample.loop_begin = 0
	sample.loop_end = length
	sample.mix_rate = samples_per_second
	sample.stereo = false
	self.volume_db = -13.0 # don't blast your ears!
	self.stream = sample # set the sample as source
	self.play()

func _process(delta):
	GenerateAndPlay()

# adapted from https://godotengine.org/qa/28685/is-it-possible-to-make-the-audio-data-in-gdscript-only
func GenerateAndPlay():
	# generate data
	var audio_buffer = PoolByteArray()

	for i in range(0, length): # for number of samples
		var sample = int(round(sin(float(j) / samples_per_second * hz * PI * 2.0))) # generate a square wave
		j += 1
		# convert to signed byte
		audio_buffer.append(sample * 127)

	# create sample from generated data
	sample.data = audio_buffer

	# setup audio stream player & play sample
	#self.play()