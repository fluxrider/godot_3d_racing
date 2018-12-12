extends KinematicBody

var speed = 2 # meters per seconds
var turn_speed = 3 # angle per seconds (rad)
var velocity = Vector3()
var facing = 0 # bird eye view angle the kart's pedal accelerates towards
var acceleration = Vector3()
var accel_decay = 3
var bounce_loss = .9
var current_slope = 0

var floor_normals = Vector3(0, 1, 0)
var turning_duration = 0 # for squeal purposes
var squealing = false

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
	var d = Vector3()
	d.x = key_fw - key_bw
	# if turning, force a small acceleration
	if abs(d.x) < .3 and turning != 0: d.x = .3
	# reverse driving is slower
	if d.x < 0: d.x /= 2
	# if not on floor, never mind acceleration
	if not self.is_on_floor():
		d.x = 0
	d.z = 0
	d.y = 0

	# rotate acceleration direction (slopes) (I found this didn't work in practice [flying], and not doing it isn't that bad)
	#var elevation = acos(floor_normals.dot(Vector3(0,1,0)))
	#var theta = atan2(floor_normals.z, floor_normals.x)
	#var factor = sin(theta + facing) # 1: climbing, -1: downhill
	#d = d.rotated(Vector3(0,0,1), elevation * factor)

	# rotate acceleration direction (facing)
	d = d.rotated(Vector3(0,1,0), facing + PI/2)

	# boost
	if Input.is_action_just_pressed("ui_accept"):
		d *= 50

	acceleration += d

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
			var before = acceleration
			acceleration = acceleration.bounce(collision.normal) * bounce_loss
			# play bounce sound, only if bounce is strong enough (arbitrary)
			if (acceleration - before).length() > 3.5:
				self.get_parent().find_node("HitWall").play()
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
		var tmp = Vector2()
		tmp.x = current_slope + (acos(floor_normals.dot(Vector3(0,1,0))) - current_slope) * .5
		current_slope = tmp.x
		tmp.y = 0
		tmp = tmp.rotated(atan2(floor_normals.z, floor_normals.x) + facing - PI/2)
		self.rotation.x = tmp.x
		self.rotation.z = tmp.y
	self.rotation.y = facing

	# tire squeal
	if not turning or acceleration.length() < 13 or sign(turning) != sign(turning_duration):
		turning_duration = 0
	turning_duration += delta * turning
	squealing = abs(turning_duration) > .4