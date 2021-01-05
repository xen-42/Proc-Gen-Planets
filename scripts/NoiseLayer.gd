extends Node
tool

var noise = OpenSimplexNoise.new()

export(int, 0, 8) var octaves = 4 setget _set_octaves
export(float, 0, 20.0) var period = 10.0 setget _set_period
export(float, 0, 1) var persistence = 0.8 setget _set_persistence
export(float, 0, 5) var noise_scale = 1 setget _set_noise_scale

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence

func modify_vertex(v):
	v += v.normalized() * ((noise.get_noise_3d(v.x, v.y, v.z) + 2) / 2.0) * noise_scale
	return v

func _set_octaves(o):
	octaves = o
	noise.octaves = o
	get_parent().update_mesh()

func _set_period(p):
	period = p
	noise.period = p
	get_parent().update_mesh()
	
func _set_persistence(p):
	persistence = p
	noise.persistence = p
	get_parent().update_mesh()

func _set_noise_scale(s):
	noise_scale = s
	get_parent().update_mesh()
