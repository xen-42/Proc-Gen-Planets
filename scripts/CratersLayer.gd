extends Node
tool

var craters_pos = []
var craters_scale = []

export(int, 0, 40) var number = 0 setget _set_number
export(float, 0.01, 10) var crater_scale = 0.5 setget _set_crater_scale
export(float, -50, 50) var depth = 1 setget _set_depth
export(float, 0.01, 5) var width = 1 setget _set_width
export(float, 0, 1) var rim_width = 0.5 setget _set_rim_width
export(float, 0, 1) var rim_steepness = 0.5 setget _set_rim_steepness
export(float, -5, 5) var crater_floor = 0.5 setget _set_crater_floor
export(float, 0.01, 1) var smoothness = 0.5 setget _set_smoothness
export(float, 0, 1) var bias = 0.5 setget _set_bias

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func generate_craters():
	for i in range(craters_pos.size(), number):
		# Pick random locations on the sphere
		var theta = rand_range(0, 2 * PI)
		var phi = rand_range(-PI, PI)
		craters_pos.append(Vector3(cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi)))
		craters_scale.append(crater_scale * bias_function(rand_range(0.1, 1)))
		
func regen_sizes():
	craters_scale = []
	for i in range(0, number):
		craters_scale.append(crater_scale * bias_function(rand_range(0.1, 1)))
		
func crater_shape(x):
	var shape = smax(cavity_shape(x), crater_floor, smoothness)
	shape = smin(shape, rim_shape(x), smoothness)
	return shape

func cavity_shape(x):
	x = x / (1 - rim_width)
	return ((x * x) - 1) * depth

func rim_shape(x):
	x = abs(x) - 1 - rim_width
	return x * x * rim_steepness

func bias_function(x):
	var k = pow(1 - bias, 3)
	return (x * k) / (x * k - x + 1)

func modify_vertex(v):
	var v_norm = v.normalized()
	#For each crater check distance between this vertex and the crater
	for i in range(0, number):
		var dist = (v_norm - craters_pos[i]).length()
		if dist < width * craters_scale[i]:
			v += crater_shape(dist / (width * craters_scale[i])) * v_norm * craters_scale[i]
	return v

func _set_number(n):
	if n > number:
		# Got to set it first before generating more
		number = n
		generate_craters()
	if n < number:
		craters_pos.resize(n)
		craters_scale.resize(n)
		number = n
	get_parent().update_mesh()
	
func _set_crater_scale(s):
	crater_scale = s
	regen_sizes()
	get_parent().update_mesh()
		
func _set_depth(d):
	depth = d
	get_parent().update_mesh()

func _set_width(w):
	width = w
	get_parent().update_mesh()

func _set_rim_width(rw):
	rim_width = rw
	get_parent().update_mesh()

func _set_rim_steepness(rs):
	rim_steepness = rs
	get_parent().update_mesh()

func _set_crater_floor(cf):
	crater_floor = cf
	get_parent().update_mesh()

func _set_smoothness(s):
	smoothness = s
	get_parent().update_mesh()

func _set_bias(b):
	bias = b
	get_parent().update_mesh()

func smin(a, b, k):
	var h = clamp((b - a + k) / (2 * k), 0, 1)
	return a * h + b * (1 - h) - k * h * (1 - h)

func smax(a, b, k):
	var h = -clamp((a - b + k) / (2 * k), -1, 0)
	return -(-a * h - b * (1 - h) - k * h * (1 - h))
