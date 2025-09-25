extends Node3D

#variables determining how peaks are generated
@export var size:int = 256
@export var spacing:float = 0.25
#@export var num_peaks:int = 64
@export var amplitude:float = 5
#var peaks = []


func _ready():
	
	#randomize()
	#_generate_peaks()
	
	var mesh_instance = MeshInstance3D.new() #create mesh
	var mat = StandardMaterial3D.new() #create material for mesh
	#mat.cull_mode = BaseMaterial3D.CULL_DISABLED 
	mat.albedo_color = Color(0.314, 0.784, 0.216, 1.0) #set color to green
	
	var img_noise = generate_FNL_Noise(size) #generate noise image
	mesh_instance.mesh = generate_grid_slow(size,.25, img_noise) #generate quad mesh with FNl image
	mesh_instance.material_override = mat #set Mesh's material
	add_child(mesh_instance) #add mesh to world
	pass
	
func generate_grid_slow(size, spacing, FNL): #creates size x size grid of points at heights calculated in get_FNL_Height
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertex_count = 0
	
	for x in range(size):
		for y in range(size):
			
			var h0 = get_FNL_Height(x,y, FNL)
			var h1 = get_FNL_Height(x+1,y, FNL)
			var h2 = get_FNL_Height(x+1, y+1, FNL)
			var h3 = get_FNL_Height(x, y+1, FNL)
			

			
			#vars changed to randomized heights
			#var h0 = get_height(x, y)
			#var h1 = get_height(x+1, y)
			#var h2 = get_height(x+1, y+1)
			#var h3 = get_height(x, y+1)
			
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
	
	
	#function for generating peaks randomly
#func _generate_peaks():
	#peaks.clear()
	#for i in range(num_peaks):
		#var px = randi() % size
		#var py = randi() % size
		#var ph = randf_range(-amplitude, amplitude)
		#peaks.append({ "pos": Vector2(px, py), "h": ph })
#
##sets point's heights around peaks to gradually approach them
#func get_height(x:int, y:int) -> float:
	#var total_weight = 0.0
	#var weighted_height = 0.0
	#for peak in peaks:
		#var dist = peak["pos"].distance_to(Vector2(x,y)) + 0.001
		#var w = 1.0 / dist
		#total_weight += w
		#weighted_height += peak["h"] * w
	#return weighted_height / total_weight

func generate_FNL_Noise(size): #Generates the noise map, this can be heavily tweaked to get ideal look for water or mountians etc
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	noise.fractal_gain = 0.5

	var img =  noise.get_seamless_image(size,size)
	save_png(img)
	
	return img

func get_FNL_Height(x,y, FNL): #takes each pixel, finds the grayscale value [-1,1] and multiplies by amplitude to increase/decrease elevation 
	var tone = FNL.get_pixel(x,y)
	var toneVal = tone.r
	return (toneVal * 2.0 - 1.0) * amplitude
	
func save_png(img): #saves FNL png for comparison after
	# Save PNG for debugging (res:// saves into your project folder)
	var save_path = "res://debug_noise.png"
	var err = img.save_png(save_path)
	if err == OK:
		print("Noise saved to ", save_path)
	else:
		print("Error saving noise image: ", err)
	
	
#function for generating peaks randomly
#func _generate_peaks():
	#peaks.clear()
	#for i in range(num_peaks):
		#var px = randi() % size
		#var py = randi() % size
		#var ph = randf_range(-amplitude, amplitude)
		#peaks.append({ "pos": Vector2(px, py), "h": ph })
#
#sets point's heights around peaks to gradually approach them
#func get_height(x:int, y:int) -> float:
	#var total_weight = 0.0
	#var weighted_height = 0.0
	#for peak in peaks:
		#var dist = peak["pos"].distance_to(Vector2(x,y)) + 0.001
		#var w = 1.0 / dist
		#total_weight += w
		#weighted_height += peak["h"] * w
	#return weighted_height / total_weight
