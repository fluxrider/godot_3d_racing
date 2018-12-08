extends KinematicBody

var speed = 2 # meters per seconds
var turn_speed = 3 # angle per seconds (rad)
var velocity = Vector3()
var facing = 0 # bird eye view angle the kart's pedal accelerates towards
var acceleration = Vector3()
var accel_decay = 3
var bounce_loss = .9

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
	d = d.rotated(-facing - PI/2)
	acceleration.x += d.x
	acceleration.z += d.y

	# apply speed and gravity
	velocity.x = acceleration.x * speed
	velocity.z = acceleration.z * speed
	velocity.y += -9.8
	# note: delta is applied magically inside move_and_slide, see doc.
	velocity = self.move_and_slide(velocity, Vector3(0,1,0))

		# friction (decay)
	acceleration -= (acceleration * accel_decay * delta)

	# collision
	var floor_normals = Vector3(0, 0 ,0)
	var floor_normals_n = 0
	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		# bounce off walls
		if collision.collider.name == "WallStaticBody":
			acceleration = acceleration.bounce(collision.normal) * bounce_loss
		# rotate to floor
		elif collision.normal.y > .5:
			floor_normals += collision.normal
			floor_normals_n += 1

	# rotate model
	if floor_normals_n == 0:
		self.rotation.x = 0
	else:
		floor_normals /= floor_normals_n
		self.rotation.x = acos(floor_normals.dot(Vector3(0,1,0))) # (slope)
	self.rotation.y = facing
	self.rotation.z = 0
	# rotate model (slope)
	#print(1 - floor_normal.dot(Vector3(0,1,0)))
	#self.rotation = self.rotation.rotated(, deg2rad(30))
