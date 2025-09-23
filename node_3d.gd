extends Node3D

var land = MeshInstance3D.new()
var st = SurfaceTool.new()

func _ready():
	st.begin(Mesh.PRIMITIVE_TRIANGLES) # mode controls kind of geometry

	st.set_uv(Vector2(0, 0))
	st.add_vertex(Vector3(0, 0, 0)) # vertex 0
	st.set_uv(Vector2(1, 0))
	st.add_vertex(Vector3(1, 0, 0)) # vertex 1
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, 0, 1)) # vertex 2
	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(0, 0, 1)) # vertex 3

	# make the first triangle
	st.add_index(0)
	st.add_index(1)
	st.add_index(2)

	# make the second triangle
	st.add_index(0)
	st.add_index(2)
	st.add_index(3)

	st.generate_normals() # normals point perpendicular up from each face

	var mesh = st.commit() # arranges mesh data structures into arrays
	land.mesh = mesh
	add_child(land)
