extends KinematicBody

var speed = 20 # meters per seconds
var jump_power = 100 # meters per seconds, injected as dirac action
var velocity = Vector3()

export(NodePath) var camera

func _physics_process(delta):
	# read joystick axis
	var d = Vector2()
	d.x = Input.get_joy_axis(0, 0)
	d.y = Input.get_joy_axis(0, 1)
	# axis deadzone
	if abs(d.x) < 0.05: d.x = 0
	if abs(d.y) < 0.05: d.y = 0
	# read keyboard
	var key_fw = Input.get_action_strength("move_forward")
	var key_bw = Input.get_action_strength("move_backward")
	var key_le = Input.get_action_strength("move_left")
	var key_ri = Input.get_action_strength("move_right")
	if key_fw != 0 and -key_fw < d.y: d.y = -key_fw
	if key_bw != 0 and key_bw > d.y: d.y = key_bw
	if key_le != 0 and -key_le < d.x: d.x = -key_le
	if key_ri != 0 and key_ri > d.x: d.x = key_ri

	# direction is relative to camera, not absolute axis
	d = d.rotated(-get_node(camera).azymuth - PI/2)

	# apply speed and gravity
	velocity.x = d.x * speed
	velocity.z = d.y * speed
	velocity.y += -9.8
	# note: delta is applied magically inside move_and_slide, see doc.
	velocity = self.move_and_slide(velocity, Vector3(0,1,0))

	# jump action (next frame)
	if self.is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y += jump_power