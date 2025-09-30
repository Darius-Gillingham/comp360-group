extends Node3D

#variables determining how peaks are generated
@export var size:int = 1024
@export var spacing:float = 1
#@export var num_peaks:int = 64
@export var amplitude:float = 5
#var peaks = []


func _ready():
	var img_noise = generate_FNL_Noise(size) #generate noise image
	var text_img = create_texture(img_noise)
	var texture = ImageTexture.create_from_image(text_img)
	#randomize()
	#_generate_peaks()
	var mesh_instance = MeshInstance3D.new() #create mesh
	var mat = StandardMaterial3D.new() #create material for mesh
	mesh_instance.material_override = mat
	
	mesh_instance.material_override.albedo_texture = texture
	
	
	#mat.cull_mode = BaseMaterial3D.CULL_DISABLED 
	#mat.albedo_color = Color(0.314, 0.784, 0.216, 1.0) #set color to green
	
	mat.albedo_texture = texture
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
			
			var u0 = x / float(size-1)
			var vu0= y/ float(size-1)
			var u1 = (x+1) / float(size-1)
			var vu1 = (y+1) / float(size-1)
			
			#random heights applied
			st.set_uv(Vector2(u0,vu0))
			st.add_vertex(Vector3(x*spacing,h0 , y*spacing)) #V0
			st.set_uv(Vector2(u1,vu0))
			st.add_vertex(Vector3((x+1)*spacing, h1, y*spacing)) #V1
			st.set_uv(Vector2(u1,vu1))
			st.add_vertex(Vector3((x+1)*spacing, h2, (y+1)*spacing)) #V2
			st.set_uv(Vector2(u0,vu1))
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
	save_png(img, "res://debug_noise.png")
	
	return img

func get_FNL_Height(x,y, FNL): #takes each pixel, finds the grayscale value [-1,1] and multiplies by amplitude to increase/decrease elevation 
	var tone = FNL.get_pixel(x,y)
	var toneVal = tone.r
	return (toneVal * 2.0 - 1.0) * amplitude

func create_texture(FNL):
	var texture = Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# --- Base terrain coloring pass ---
	for x in range(size):
		for y in range(size):
			var tone = FNL.get_pixel(x, y)
			var t = tone.r

			if (0.75 <= t and t < 1.0):
				# high = snow (white)
				texture.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0))

			elif (0.60 <= t and t < 0.75):
				# foothills below snow = grey
				texture.set_pixel(x, y, Color(0.535, 0.646, 0.673, 1.0))

			elif (0.20 <= t and t < 0.75):
				# middle zone = mostly grey, but green dominates in lower middle
				if (0.35 <= t and t < 0.6):
					# ~80% green, 20% variation
					var roll = rng.randf()
					if roll < 0.8:
						texture.set_pixel(x, y, Color(0.0, 0.472, 0.162, 1.0)) # green
					elif roll < 0.9:
						texture.set_pixel(x, y, Color(0.201, 0.541, 0.332, 1.0)) # same green again
					else:
						texture.set_pixel(x, y, Color(0.219, 0.583, 0.347, 1.0)) # olive green
				else:
					
					texture.set_pixel(x, y, Color(0.0, 0.392, 0.152, 1.0))

			else:
				# low = water (blue)
				texture.set_pixel(x, y, Color(0.0, 0.188, 1.0, 1.0))

	# --- Stream generation pass (nested inside create_texture) ---
	var num_streams = 20
	var stream_starts = []

	# collect shoreline pixels
	for x in range(1, size - 1):
		for y in range(1, size - 1):
			var t = FNL.get_pixel(x, y).r
			if t < 0.20:
				# check neighbors for land
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						if dx == 0 and dy == 0:
							continue
						var nt = FNL.get_pixel(x + dx, y + dy).r
						if nt >= 0.20:
							stream_starts.append(Vector2i(x, y))
							break

	# pick random stream starts from shoreline
	stream_starts.shuffle()
	stream_starts = stream_starts.slice(0, min(num_streams, stream_starts.size()))

	for start in stream_starts:
		var x = start.x
		var y = start.y
		var length = rng.randi_range(30, 100) # stream length

		for step in range(length):
			# mark stream pixel
			texture.set_pixel(x, y, Color(0.0, 0.0, 0.7, 1.0)) # dark blue stream

			# pick next step uphill
			var best_pos = Vector2i(x, y)
			var best_height = -1.0

			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if dx == 0 and dy == 0:
						continue
					var nx = clamp(x + dx, 0, size - 1)
					var ny = clamp(y + dy, 0, size - 1)
					var nh = FNL.get_pixel(nx, ny).r
					if nh > best_height and nh < 0.8: # stop before snow
						best_height = nh
						best_pos = Vector2i(nx, ny)

			# if we can't go higher, stop
			if best_pos == Vector2i(x, y):
				break

			# move to next position
			x = best_pos.x
			y = best_pos.y


	save_png(texture, "res://textMap.png")
	return texture



	
func save_png(img, path): #saves FNL png for comparison after
	# Save PNG for debugging (res:// saves into your project folder)
	var save_path = path
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
