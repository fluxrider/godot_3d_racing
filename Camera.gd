extends Camera

var h_speed = 5 # angle per seconds (rad)
var v_speed = 5 # angle per seconds (rad)
var d_speed = 10 # meters per seconds
var elevation = -PI/4 # angle (rad)
var azymuth = 0 # angle (rad)
var distance = 13.5 # meters

# the target is typically the player node
export(NodePath) var target

func _process(delta):
	# read joystick axis and inputs
	var h = Input.get_joy_axis(0, 2)
	var v = Input.get_joy_axis(0, 3)
	var d = Input.get_action_strength("camera_zoom_out") - Input.get_action_strength("camera_zoom_in")
	# axis deadzone
	if abs(h) < 0.05: h = 0
	if abs(v) < 0.05: v = 0
 	# read keyboard
	var key_le = Input.get_action_strength("cam_left")
	var key_ri = Input.get_action_strength("cam_right")
	var key_dw = Input.get_action_strength("cam_down")
	var key_up = Input.get_action_strength("cam_up")
	if key_le != 0 and -key_le < h: h = -key_le
	if key_ri != 0 and key_ri > h: h = key_ri
	if key_dw != 0 and key_dw > v: v = key_dw
	if key_up != 0 and -key_up < v: v = -key_up


	# move camera
	elevation += v * v_speed * delta
	azymuth += h * h_speed * delta
	distance += d * d_speed * delta
	# caps
	if distance < 0: distance = 0

	# rotate (azymuth)
	var p = Vector3(cos(-azymuth), 0, sin(-azymuth))
	p *= distance
	# get perpendicular axis to 3D rotate (elevation)
	var axis = Vector3(p.z, 0, -p.x).normalized()
	# rotate both camera and up vector
	var p_up = Vector3(p.x, 1, p.z)
	p = p.rotated(axis, elevation)
	p_up = p_up.rotated(axis, elevation)
	# follow target
	var t = get_node(target).translation
	self.translation = t + p
	# look at target
	self.look_at(t, p_up - p)
