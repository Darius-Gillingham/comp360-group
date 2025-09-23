extends MeshInstance3D

var land = MeshInstance3D.new()
var st = SurfaceTool.new()

func _ready():
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Define 8 vertices of a cube
	var v = [
		Vector3(-0.5, -0.5, -0.5), # 0
		Vector3( 0.5, -0.5, -0.5), # 1
		Vector3( 0.5,  0.5, -0.5), # 2
		Vector3(-0.5,  0.5, -0.5), # 3
		Vector3(-0.5, -0.5,  0.5), # 4
		Vector3( 0.5, -0.5,  0.5), # 5
		Vector3( 0.5,  0.5,  0.5), # 6
		Vector3(-0.5,  0.5,  0.5)  # 7
	]

	# Each cube face = 2 triangles (6 indices)
	var faces = [
		[0, 1, 2, 3], # back
		[5, 4, 7, 6], # front
		[4, 0, 3, 7], # left
		[1, 5, 6, 2], # right
		[3, 2, 6, 7], # top
		[4, 5, 1, 0]  # bottom
	]

	for f in faces:
		# Triangle 1
		st.add_vertex(v[f[0]])
		st.add_vertex(v[f[1]])
		st.add_vertex(v[f[2]])
		# Triangle 2
		st.add_vertex(v[f[0]])
		st.add_vertex(v[f[2]])
		st.add_vertex(v[f[3]])

	st.generate_normals()
	var mesh = st.commit()

	land.mesh = mesh
	add_child(land)
