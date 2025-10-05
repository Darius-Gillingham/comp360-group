extends Node3D

#variables determining how peaks are generated
@export var size:int = 1024
@export var spacing:float = .25
@export var amplitude:float = 5
@export var biome = "Dunes" #Forest, Alpine, Coast, Dunes

func _ready():
	var mesh_instance = MeshInstance3D.new() #create mesh
	var mat = StandardMaterial3D.new() #create material for mesh
	mesh_instance.material_override = mat
	
	if biome == "Dunes":
		amplitude = 3
		var img_noise = generate_dune_Noise(size)
		var text_img = create_dune_texture(img_noise)
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size,spacing, img_noise)
	elif biome == "Forest":
		amplitude = 3 #desired amplitude for your biome
		var img_noise = generate_dune_Noise(size) #Your biomes noise func
		var text_img = create_dune_texture(img_noise) #Your biomes texture func
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size,spacing, img_noise)
	elif biome == "Alpine":
		#Meant to look more like Ice Spikes, like the biome from Minecraft.
		amplitude = 10 
		var img_noise = generate_alpine_Noise(size) 
		var text_img = create_alpine_texture(img_noise) 
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size,spacing, img_noise)
	elif biome == "Coast":
		amplitude = 5 #desired amplitude for your biome
		var img_noise = generate_Coastal_Noise(size) #Your biomes noise func
		var text_img = create_Coastal_Texture(img_noise) #Your biomes texture func
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size,spacing, img_noise)
	else: 
		var img_noise = generate_FNL_Noise(size)
		var text_img = create_texture(img_noise)
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size,spacing, img_noise)
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
func get_FNL_Height(x,y, FNL): #takes each pixel, finds the grayscale value [-1,1] and multiplies by amplitude to increase/decrease elevation 
	var tone = FNL.get_pixel(x,y)
	var toneVal = tone.r
	return (toneVal * 3.5 - 1.0) * amplitude



func generate_dune_Noise(size): #Generates the dune noise map, this can be heavily tweaked to get ideal look for water or mountians etc
	var dune_noise = FastNoiseLite.new()
	dune_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	dune_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	dune_noise.fractal_octaves = 1.3
	dune_noise.frequency = .02
	dune_noise.fractal_gain = .3

	var img =  dune_noise.get_seamless_image(size,size)
	save_png(img, "res://debug_noise.png")

	return img

func generate_forest_Noise(size):
	pass
func generate_alpine_Noise(size):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	noise.fractal_octaves = 9
	noise.fractal_gain = 0.5

	var img =  noise.get_seamless_image(size,size)
	save_png(img, "res://debug_noise.png")
	
	return img
	

func generate_FNL_Noise(size):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	noise.fractal_gain = 0.5
	var img =  noise.get_seamless_image(size,size)
	save_png(img, "res://debug_noise.png")
	return img


func create_dune_texture(FNL):
	var dune_texture = Image.create_empty(size,size, false, Image.FORMAT_RGBA8)
	for x in range(size):
		for y in range(size):
			var dune_tone = FNL.get_pixel(x,y)
			if (.75 <= dune_tone.r) and (dune_tone.r <= 1):
				dune_texture.set_pixel(x,y, Color(0.988, 0.741, 0.463, 1.0)) # dune peak (highest)
			elif (.25 <= dune_tone.r) and (dune_tone.r < .75):
				dune_texture.set_pixel(x,y, Color(0.886, 0.62, 0.365, 1.0)) # dune middle
			elif (.15 <= dune_tone.r) and (dune_tone.r < .25):
				dune_texture.set_pixel(x,y, Color(0.773, 0.522, 0.31, 1.0)) # dune lower
			else:
				dune_texture.set_pixel(x,y, Color(0.18, 0.302, 0.529, 1.0)) # oasis (lowest)
	save_png(dune_texture, "res://textMap_DUNE.png")
	return dune_texture
func create_forest_texture(FNL):
	pass
func create_alpine_texture(FNL):
	var texture = Image.create_empty(size,size, false, Image.FORMAT_RGBA8)
	for x in range(size):
		for y in range(size):
			var tone = FNL.get_pixel(x,y).r
			if tone < 0.166:
				texture.set_pixel(x,y, Color(0.0, 0.0, 0.3, 1.0)) # deep dark blue
			elif tone < 0.333:
				texture.set_pixel(x,y, Color(0.0, 0.1, 0.5, 1.0)) # dark blue
			elif tone < 0.5:
				texture.set_pixel(x,y, Color(0.0, 0.3, 0.7, 1.0)) # medium blue
			elif tone < 0.666:
				texture.set_pixel(x,y, Color(0.4, 0.6, 0.9, 1.0)) # light icy blue
			elif tone < 0.833:
				texture.set_pixel(x,y, Color(0.8, 0.85, 0.9, 1.0)) # frosty gray-white
			else:
				texture.set_pixel(x,y, Color(1.0, 1.0, 1.0, 1.0)) # bright white
				
	save_png(texture, "res://textMap.png")
	return texture

func create_texture(FNL):
	pass
	
func create_Coastal_Texture(FNL):
	var texture = Image.create_empty(size,size, false, Image.FORMAT_RGBA8)
	for x in range(size):
		for y in range(size):
			var tone = FNL.get_pixel(x,y)
			if (.75 <= tone.r) and (tone.r <= 1):
				texture.set_pixel(x,y, Color(0.254, 0.54, 0.091, 1.0))
			elif (.65 <= tone.r) and (tone.r < .75):
				texture.set_pixel(x,y, Color(0.444, 0.529, 0.084, 1.0))
			elif (.05 <= tone.r) and (tone.r < .65):
				texture.set_pixel(x,y, Color(0.781, 0.781, 0.781, 1.0))
			else:
				texture.set_pixel(x,y, Color(0.035, 0.506, 0.655, 1.0))
	save_png(texture, "res://textMap_COAST.png")
	return texture
	
func save_png(img, path): #saves FNL png for comparison after
	# Save PNG for debugging (res:// saves into your project folder)
	var save_path = path
	var err = img.save_png(save_path)
	if err == OK:
		print("Noise saved to ", save_path)
	else:
		print("Error saving noise image: ", err)

func generate_Coastal_Water_Noise(size):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	#noise.seed = 1311
	noise.frequency = 0.01
	
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 1.8
	noise.fractal_gain = 1
	noise.fractal_weighted_strength = 25
	
	var img =  noise.get_image(size,size,true, false, false)
	
	return img
	
func generate_Coastal_Deform_Noise(size):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.01
	
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 2
	noise.fractal_gain = 1
	noise.fractal_weighted_strength = 1
	
	var img =  noise.get_image(size,size,true, false, false)
	
	return img
	
func generate_Coastal_Noise(size):
	var grad = Gradient.new()
	
	var black_start_percent = 0.57
	var white_start_percent = 0.63
	
	grad.add_point(black_start_percent, Color.BLACK)
	grad.add_point(white_start_percent, Color.WHITE)
	
	var grad_text = GradientTexture2D.new()
	grad_text.gradient = grad
	grad_text.height = size
	grad_text.width = size

	var img =  grad_text.get_image()
	
	var white_start_pixel = size * white_start_percent
	var island_add_range_start = white_start_pixel - 120
	
	var grey_start_threshold = white_start_pixel - 90
	
	var noise = generate_Coastal_Water_Noise(size)
	
	for x in range(island_add_range_start, white_start_pixel):
		for y in range(size):
			var grey_add = max(-(x - grey_start_threshold), 0) / 30
			var color = noise.get_pixel(x,y) + img.get_pixel(x,y) - Color(grey_add, grey_add, grey_add, 1.0)
			#var color = noise.get_pixel(x,y) * noise.get_pixel(x,y) 
			img.set_pixel(x,y,color)
			
	var deform_noise = generate_Coastal_Deform_Noise(size)
	for x in range(size):
		for y in range(size):
			var grey_amount = deform_noise.get_pixel(x,y).r
			grey_amount *= 0.5
			var color = img.get_pixel(x,y) - Color(grey_amount, grey_amount, grey_amount, 1)
			#print(color)
			#var color = noise.get_pixel(x,y) * noise.get_pixel(x,y) 
			img.set_pixel(x,y,color)
	
	return img
