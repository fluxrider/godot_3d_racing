extends KinematicBody

var speed = 2 # meters per seconds
var turn_speed = 3 # angle per seconds (rad)
var velocity = Vector3()
var facing = 0 # bird eye view angle the kart's pedal accelerates towards
var acceleration = Vector3()
var accel_decay = 3
var bounce_loss = .9
var current_slope = 0

var floor_normals = Vector3()
var turning_duration = 0 # for squeal purposes

export(NodePath) var camera

func _physics_process(delta):
	var key_fw = Input.get_action_strength("move_forward")
	var key_bw = Input.get_action_strength("move_backward")
	var key_le = Input.get_action_strength("move_left")
	var key_ri = Input.get_action_strength("move_right")

	# rotate
	var turning = (key_ri - key_le)
	facing += turning * -turn_speed * delta

		# acceleration
	var d = Vector2()
	d.x = key_fw - key_bw
	# if turning, force a small acceleration
	if abs(d.x) < .3 and turning != 0: d.x = .3
	# reverse driving is slower
	if d.x < 0: d.x /= 2
	# if not on floor, never mind acceleration
	if not self.is_on_floor():
		d.x = 0
	d.y = 0

	# rotate acceleration direction (facing)
	d = d.rotated(-facing - PI/2)

	# boost
	if Input.is_action_just_pressed("ui_accept"):
		d *= 50

	acceleration.x += d.x
	acceleration.z += d.y

	# TODO rotate acceleration direction (slopes)

	# apply speed and gravity
	velocity.x = acceleration.x * speed
	velocity.z = acceleration.z * speed
	velocity.y += -9.8 + acceleration.y * speed
	# note: delta is applied magically inside move_and_slide, see doc.
	velocity = self.move_and_slide(velocity, Vector3(0,1,0))

		# friction (decay)
	acceleration -= (acceleration * accel_decay * delta)

	# collision
	floor_normals = Vector3(0, 0 ,0)
	var floor_normals_n = 0
	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		# bounce off walls
		if collision.normal.y < .2:
			acceleration = acceleration.bounce(collision.normal) * bounce_loss
		# rotate to floor
		elif collision.normal.y > .5:
			floor_normals += collision.normal
			floor_normals_n += 1

	# rotate model
	if floor_normals_n == 0:
		floor_normals = Vector3(0, 1, 0)
		self.rotation.x = 0
		self.rotation.z = 0
	else:
		floor_normals /= floor_normals_n
		# slope (smoothed)
		d.x = current_slope + (acos(floor_normals.dot(Vector3(0,1,0))) - current_slope) * .1
		current_slope = d.x
		d.y = 0
		d = d.rotated(facing - PI/2)
		self.rotation.x = d.x
		self.rotation.z = d.y
	self.rotation.y = facing

	# engine sound
	get_parent().find_node("Engine").set_hz(6 + acceleration.length() * 2)

	# tire squeal
	if not turning or acceleration.length() < 13 or sign(turning) != sign(turning_duration):
		turning_duration = 0
	turning_duration += delta * turning
	if abs(turning_duration) > .4:
		get_parent().find_node("Squeal").set_hz(120 - acceleration.length() + OS.get_ticks_msec() % 10)
	else:
		get_parent().find_node("Squeal").set_hz(0)
