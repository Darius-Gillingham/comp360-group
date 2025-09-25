extends Node3D

#variables determining how peaks are generated
@export var size:int = 25
@export var spacing:float = 0.25
@export var num_peaks:int = 64
@export var amplitude:float = 0.5

var peaks = []

#function for generating peaks randomly
func _generate_peaks():
	peaks.clear()
	for i in range(num_peaks):
		var px = randi() % size
		var py = randi() % size
		var ph = randf_range(-amplitude, amplitude)
		peaks.append({ "pos": Vector2(px, py), "h": ph })

#sets point's heights around peaks to gradually approach them
func get_height(x:int, y:int) -> float:
	var total_weight = 0.0
	var weighted_height = 0.0
	for peak in peaks:
		var dist = peak["pos"].distance_to(Vector2(x,y)) + 0.001
		var w = 1.0 / dist
		total_weight += w
		weighted_height += peak["h"] * w
	return weighted_height / total_weight


func _ready():
	randomize()
	_generate_peaks()
	
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
			
			#vars changed to randomized heights
			var h0 = get_height(x, y)
			var h1 = get_height(x+1, y)
			var h2 = get_height(x+1, y+1)
			var h3 = get_height(x, y+1)
			
			#random heights applied
			st.set_uv(Vector2(0,0))
			st.add_vertex(Vector3(x*spacing,h0 , y*spacing)) #V0
			st.set_uv(Vector2(1,0))
			st.add_vertex(Vector3((x+1)*spacing, h1, y*spacing)) #V1
			st.set_uv(Vector2(1,1))
			st.add_vertex(Vector3((x+1)*spacing, h2, (y+1)*spacing)) #V2
			st.set_uv(Vector2(0,1))
			st.add_vertex(Vector3(x*spacing, h3, (y+1)*spacing)) #V3
			
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
