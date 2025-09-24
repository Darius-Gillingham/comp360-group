extends Node3D

func _ready():
	var mesh_instance = MeshInstance3D.new()
	var mat = StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	mesh_instance.mesh = generate_grid_slow(25,.25)
	mesh_instance.material_override = mat
	add_child(mesh_instance)
	pass
	
func generate_grid_slow(size, spacing):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertex_count = 0
	
	for x in range(size):
		for y in range(size):
			var v0_pos = Vector3(x * spacing, y * spacing, 0)
			var v1_pos = Vector3((x + 1) * spacing, y * spacing, 0)
			var v2_pos = Vector3((x + 1) * spacing, (y + 1) * spacing, 0)
			var v3_pos = Vector3(x * spacing, (y + 1) * spacing, 0)
			
			st.set_uv(Vector2(0,0))
			st.add_vertex(Vector3(x*spacing,0 , y*spacing)) #V0
			st.set_uv(Vector2(1,0))
			st.add_vertex(Vector3((x+1)*spacing, 0, y*spacing)) #V1
			st.set_uv(Vector2(1,1))
			st.add_vertex(Vector3((x+1)*spacing, 0, (y+1)*spacing)) #V2
			st.set_uv(Vector2(0,1))
			st.add_vertex(Vector3(x*spacing, 0, (y+1)*spacing)) #V3
			
			var v0 = vertex_count
			var v1 = vertex_count + 1
			var v2 = vertex_count + 2
			var v3 = vertex_count + 3

			# First triangle (V0, V1, V2)
			st.add_index(v0)
			st.add_index(v1)
			st.add_index(v2)

			# Second triangle (V0, V2, V3)
			st.add_index(v0)
			st.add_index(v2)
			st.add_index(v3)
			
			vertex_count += 4
	st.generate_normals() # normals point perpendicular up from each face
	print(vertex_count/4, " quads printed")
	return st.commit() # arranges mesh data structures into arrays
