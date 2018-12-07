extends KinematicBody

var speed = 2 # meters per seconds
var turn_speed = 3 # angle per seconds (rad)
var velocity = Vector3()
var facing = 0 # bird eye view angle the kart's pedal accelerates towards
var acceleration = Vector3()
#var accel_cap = 20
var accel_decay = 3

export(NodePath) var camera

func _physics_process(delta):
	var key_fw = Input.get_action_strength("move_forward")
	var key_bw = Input.get_action_strength("move_backward")
	var key_le = Input.get_action_strength("move_left")
	var key_ri = Input.get_action_strength("move_right")

	# rotate
	var turning = (key_ri - key_le)
	#if key_bw: turning = -turning # reverse control in reverse
	facing += turning * -turn_speed * delta

	# rotate model
	self.rotation.x = PI / 2
	self.rotation.y = 0
	self.rotation.z = -facing

	# acceleration
	var d = Vector2()
	d.x = key_fw - key_bw
	# if turning, force a small acceleration
	if abs(d.x) < .3 and turning != 0: d.x = .3
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

	# friction (cap)
	#if acceleration.length() > accel_cap:
	#	acceleration = acceleration.normalized() * accel_cap
	# friction (decay)
	acceleration -= (acceleration * accel_decay * delta)