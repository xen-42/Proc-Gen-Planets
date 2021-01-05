extends Spatial
tool

onready var mesh_instance = null

var tmpMesh = null
var UVs = PoolVector2Array()
var color = Color(1.0, 1.0, 1.0)
var st = SurfaceTool.new()

var min_height = INF
var max_height = 0

# For Icosphere
export(int, 0, 6) var recursion_level setget _set_recursion_level
export(int, 1, 100) var radius setget _set_radius

# For material
export(Material) var material = Material.new()
export(Gradient) var gradient = Gradient.new()

func _ready():
	randomize()
	update_mesh()
	
func update_mesh():
	var tmpMesh = Mesh.new()
	
	# Reset the mesh
	for c in get_children():
		if c is MeshInstance:
			c.queue_free()
	mesh_instance = MeshInstance.new()
	mesh_instance.material_override = material
	self.add_child(mesh_instance)
	
	#Create icosphere
	var t = (1.0 + sqrt(5.0)) / 2.0
	
	var v0 = Vector3(-1,  t,  0).normalized()
	var v1 = Vector3( 1,  t,  0).normalized()
	var v2 = Vector3(-1, -t,  0).normalized()
	var v3 = Vector3( 1, -t,  0).normalized()

	var v4 = Vector3( 0, -1,  t).normalized()
	var v5 = Vector3( 0,  1,  t).normalized()
	var v6 = Vector3( 0, -1, -t).normalized()
	var v7 = Vector3( 0,  1, -t).normalized()

	var v8 = Vector3( t,  0, -1).normalized()
	var v9 = Vector3( t,  0,  1).normalized()
	var v10 = Vector3(-t,  0, -1).normalized()
	var v11 = Vector3(-t,  0,  1).normalized()
	
	var vertices = [v0, v1, v2, v3, v4,
		v5, v6, v7, v8, v9, v10, v11]

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_smooth_group(true)
	st.add_uv(Vector2(0, 0))
	var vertex_indices = []

	vertex_indices.append([0, 11, 5])
	vertex_indices.append([0, 5, 1])
	vertex_indices.append([0, 1, 7])
	vertex_indices.append([0, 7, 10])
	vertex_indices.append([0, 10, 11])

	vertex_indices.append([1, 5, 9])
	vertex_indices.append([5, 11, 4])
	vertex_indices.append([11, 10, 2])
	vertex_indices.append([10, 7, 6])
	vertex_indices.append([7, 1, 8])
	
	vertex_indices.append([3, 9, 4])
	vertex_indices.append([3, 4, 2])
	vertex_indices.append([3, 2, 6])
	vertex_indices.append([3, 6, 8])
	vertex_indices.append([3, 8, 9])
	
	vertex_indices.append([4, 9, 5])
	vertex_indices.append([2, 4, 11])
	vertex_indices.append([6, 2, 10])
	vertex_indices.append([8, 6, 7])
	vertex_indices.append([9, 8, 1])
	
	var faces = []
	for indices in vertex_indices:
		faces.append([
			vertices[indices[0]],
			vertices[indices[1]],
			vertices[indices[2]]
		])
	
	# Refine the faces
	for i in range(0, recursion_level):
		var new_faces = []
		for triangle in faces:
			var tri_v0 = triangle[0]
			var tri_v1 = triangle[1]
			var tri_v2 = triangle[2]
			
			var a = get_midpoint(tri_v0, tri_v1)
			var b = get_midpoint(tri_v1, tri_v2)
			var c = get_midpoint(tri_v2, tri_v0)
			
			new_faces.append([tri_v0, a, c])
			new_faces.append([tri_v1, b, a])
			new_faces.append([tri_v2, c, b])
			new_faces.append([a, b, c])
		faces = new_faces
	
	vertices = []
	for face in faces:
		#Modify with noise
		face[0] = modify_vertex(face[0])
		face[1] = modify_vertex(face[1])
		face[2] = modify_vertex(face[2])
	
	for triangle in faces:
		create_quad(triangle)

	st.generate_normals(false)
	st.commit(tmpMesh)

	mesh_instance.set_mesh(tmpMesh)
	
	# Shader params
	material.set_shader_param("min_height", min_height)
	material.set_shader_param("max_height", max_height)
	var gradient_texture = GradientTexture.new()
	gradient_texture.set_gradient(gradient)
	material.set_shader_param("gradient", gradient_texture)

func modify_vertex(v):
	# Scale up
	v *= radius
	for c in get_children():
		if c.has_method("modify_vertex"):
			v = c.modify_vertex(v)
	return v

func create_quad(t):
	st.add_triangle_fan(([t[2], t[1], t[0]]))
	for v in t:
		var height = v.length()
		if height > max_height:
			max_height = height
		if height < min_height and height != 0:
			min_height = height

func get_midpoint(v1, v2):
	var midpoint = (v1 + v2) / 2.0
	midpoint = midpoint.normalized()
	return midpoint

func _set_recursion_level(rl):
	recursion_level = rl
	update_mesh()
	
func _set_radius(r):
	radius = r
	update_mesh()
