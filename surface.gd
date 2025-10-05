extends Node3D

#variables determining how peaks are generated
@export var size:int = 1024
@export var spacing:float = .25
@export var amplitude:float = 5
@export var biome = "Forest" #Forest, Alpine, Coast, Dunes
@onready var tile_map:TileMap = $TileMap #Used in generate island functions

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
		amplitude = 2
		var img_noise = generate_forest_Noise(size)
		var text_img = create_forest_texture(img_noise)
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size, spacing, img_noise)
		add_child(mesh_instance)
		add_bushes(img_noise, spacing, Color(0.0, 0.336, 0.038, 1.0))
		

		
	elif biome == "Alpine":
		#Meant to look more like Ice Spikes, like the biome from Minecraft.
		amplitude = 10 
		var img_noise = generate_alpine_Noise(size) 
		var text_img = create_alpine_texture(img_noise) 
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size,spacing, img_noise)
	elif biome == "Islands":
		amplitude = 7
		var img_noise = generate_island_Noise(false) 
		var text_img = create_island_texture(img_noise)
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size, spacing, img_noise)	
	elif biome == "Islands_Blocky":
		amplitude = 3
		var img_noise = generate_island_Noise(true) 
		var text_img = create_island_blocky_texture(img_noise)
		var texture = ImageTexture.create_from_image(text_img)
		mat.albedo_texture = texture
		mat.albedo_texture = texture
		mesh_instance.mesh = generate_grid_slow(size, spacing, img_noise)		
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
	var forest_noise = FastNoiseLite.new()
	forest_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX 
	forest_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	forest_noise.fractal_octaves = 3
	forest_noise.frequency = 0.005
	forest_noise.fractal_gain = 0.4
	forest_noise.fractal_lacunarity = 1.8 
	var img = forest_noise.get_seamless_image(size, size)
	save_png(img, "res://debug_noise_FOREST.png")
	return img
	
func generate_alpine_Noise(size):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	noise.fractal_octaves = 9
	noise.fractal_gain = 0.5

	var img =  noise.get_seamless_image(size,size)
	save_png(img, "res://debug_noise.png")
	
	return img
	
func generate_island_Noise(blocky):
	#Using tilemap, rng, and random noise function generate an island pattern with streams flowing between them.
	#Use built in random number generator
	var rng = RandomNumberGenerator.new()
	var noise = FastNoiseLite.new()
	# Create list for tile types	
	var tiles_list: Array[Vector2i] = []
	
	# Add the tiles from the tile_map
	tiles_list.append(TileDictonary.WATER)
	tiles_list.append(TileDictonary.SAND)
	tiles_list.append(TileDictonary.GRASS)
	tiles_list.append(TileDictonary.DARK_GRASS)
	tiles_list.append(TileDictonary.ROCK)
	tiles_list.append(TileDictonary.DARK_ROCK)
	
	# Store noise vlues for smooth color transitions
	var noise_values = []
	
	#In FastNoiseLite (noise) generate a seed
	rng.randomize()
	noise.seed = rng.randi_range(0, 500)
	
	#Fast Noise Lite Settings to create the isalnd shape wanted.
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX #Creates the Circles within circles for elevation
	noise.frequency = 0.01  # Lower frequency = larger features
	noise.fractal_octaves = tiles_list.size() #Fractal_octaves defines the seperated islands more
	noise.fractal_gain = 0.0 #Lower gain = larger features 
	
	
	#For loop to go iterate the width and height of the screen
	for x in range(size):
		noise_values.append([])
		for y in range(size):
			#generates the noise for the x and y position
			var abs_noise = abs(noise.get_noise_2d(x,y))
			
			noise_values[x].append(abs_noise)
			
			
			#places tiles for each pixel from generated to the noise map
			var tiles_to_place = floori(abs_noise * tiles_list.size())
			tile_map.set_cell(0, Vector2i(x, y), 0, tiles_list[tiles_to_place])
			
			
	
	var image = tilemap_to_png(noise_values, blocky)
	tile_map.visible = false
	return image

func tilemap_to_png(noise_values, blocky, filename: String = "debug_noise.png"):
	# Create an image to render to
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	# Get tilemap data and convert to colors
	for x in range(size):
		for y in range(size):
			var raw_noise = noise_values[x][y]
			var tile_data = tile_map.get_cell_atlas_coords(0, Vector2i(x, y))
			var color
			if blocky == true:
				color = get_color_from_tile(tile_data)
			else: 
				color = get_continous_grey_colour(raw_noise)
			
			image.set_pixel(x, y, color)
	
		# Save the image
	image.save_png("res://" + filename)
	print("Saved tilemap as: user://" + filename)
	return image
			
			
func get_continous_grey_colour(noise_value: float) -> Color: #Important for Island functions, check TileMap and converts it into grey tiles
	#Simple continous greyscale mapping
	var min_brightness = 0.1
	
	var max_brightness = 0.6
	
	#Invert so higher elevation = darker
	var brightness = min_brightness + (noise_value * (max_brightness - min_brightness))
	brightness = clamp(brightness, min_brightness, max_brightness)
	
	return Color(brightness, brightness, brightness)


func get_color_from_tile(tile_coord: Vector2i) -> Color:
	# Map tile types to grey shades (lighter = lower elevation, darker = higher elevation)
	match tile_coord:
		TileDictonary.WATER:
			return Color(0.1, 0.1, 0.1)  # Light grey (lowest elevation)
		TileDictonary.SAND:
			return Color(0.25, 0.25, 0.25)  # Light-medium grey
		TileDictonary.GRASS:
			return Color(0.3, 0.3, 0.3)  # Medium grey
		TileDictonary.DARK_GRASS:
			return Color(0.45, 0.45, 0.45)  # Medium-dark grey
		TileDictonary.ROCK: 
			return Color(0.65, 0.65, 0.65)  # Dark grey
		TileDictonary.DARK_ROCK:
			return Color(0.8, 0.8, 0.8)  # Very dark grey (highest elevation)
		_:
			return Color(0.9, 0.9, 0.9)  # Default very light grey


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
	var texture = Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# --- Terrain coloration ---
	for x in range(size):
		for y in range(size):
			var tone = FNL.get_pixel(x, y).r

			if tone >= 0.75:
				texture.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0)) # snow
			elif tone >= 0.6:
				texture.set_pixel(x, y, Color(0.535, 0.646, 0.673, 1.0)) # rocky
			elif tone >= 0.35:
				# forest greens
				var roll = rng.randf()
				if roll < 0.7:
					texture.set_pixel(x, y, Color(0.0, 0.45, 0.16, 1.0))
				elif roll < 0.9:
					texture.set_pixel(x, y, Color(0.2, 0.55, 0.33, 1.0))
				else:
					texture.set_pixel(x, y, Color(0.25, 0.6, 0.35, 1.0))
			elif tone >= 0.2:
				texture.set_pixel(x, y, Color(0.0, 0.392, 0.152, 1.0)) # dark forest base
			else:
				texture.set_pixel(x, y, Color(0.0, 0.188, 1.0, 1.0)) # water

	# --- Stream generation ---
	var num_streams = 20
	var stream_starts = []

	for sx in range(1, size - 1):
		for sy in range(1, size - 1):
			var t = FNL.get_pixel(sx, sy).r
			if t < 0.20:
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						if dx == 0 and dy == 0:
							continue
						var nt = FNL.get_pixel(sx + dx, sy + dy).r
						if nt >= 0.20:
							stream_starts.append(Vector2i(sx, sy))
							break

	stream_starts.shuffle()
	stream_starts = stream_starts.slice(0, min(num_streams, stream_starts.size()))

	for start in stream_starts:
		var x = start.x
		var y = start.y
		var length = rng.randi_range(30, 100)

		for step in range(length):
			texture.set_pixel(x, y, Color(0.0, 0.0, 0.7, 1.0))
			var best_pos = Vector2i(x, y)
			var best_height = -1.0

			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if dx == 0 and dy == 0:
						continue
					var nx = clamp(x + dx, 0, size - 1)
					var ny = clamp(y + dy, 0, size - 1)
					var nh = FNL.get_pixel(nx, ny).r
					if nh > best_height and nh < 0.8:
						best_height = nh
						best_pos = Vector2i(nx, ny)

			if best_pos == Vector2i(x, y):
				break

			x = best_pos.x
			y = best_pos.y

	save_png(texture, "res://textMap_FOREST.png")
	return texture


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
	
func create_island_texture(FNL):
	var texture = Image.create_empty(size,size, false, Image.FORMAT_RGBA8)
	for x in range(size):
		for y in range(size):
			var tone = FNL.get_pixel(x,y) 
			if (.45<= tone.r) and (tone.r < 1):
				texture.set_pixel(x,y, Color(0.361, 0.604, 0.271, 1.0))
			elif (.3<=tone.r) and (tone.r < .45):
				texture.set_pixel(x,y, Color(0.528, 0.543, 0.559, 1.0))
			elif (.25<=tone.r) and (tone.r < .3):
				texture.set_pixel(x,y, Color(0.543, 0.396, 0.274, 1.0))
			elif (.225<=tone.r) and (tone.r < .25):
				texture.set_pixel(x,y, Color(0.848, 0.742, 0.579, 1.0))
			else: 
				texture.set_pixel(x,y, Color(0.357, 0.547, 0.671, 1.0))
	save_png(texture, "res://textMap_ISLANDS.png") 
	return texture
	
	
func create_island_blocky_texture(FNL): 
	var texture = Image.create_empty(size,size, false, Image.FORMAT_RGBA8)
	for x in range(size):
		for y in range(size):
			var tone = FNL.get_pixel(x,y) 
			if (.8<= tone.r) and (tone.r < 1):
				texture.set_pixel(x,y, Color(0.361, 0.604, 0.271, 1.0))
			elif (.445<=tone.r) and (tone.r < .8):
				texture.set_pixel(x,y, Color(0.528, 0.543, 0.559, 1.0))
			elif (.25<=tone.r) and (tone.r < .445):
				texture.set_pixel(x,y, Color(0.543, 0.396, 0.274, 1.0))
			elif (.2<=tone.r) and (tone.r < .25):
				texture.set_pixel(x,y, Color(0.824, 0.711, 0.539, 1.0))
			else: 
				texture.set_pixel(x,y, Color(0.357, 0.547, 0.671, 0.5))
	save_png(texture, "res://textMap_ISLANDS.png") 
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
	
	
func add_bushes(FNL, spacing: float, bush_color: Color):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# --- Prebuild 4 slight variations of leaf textures ---
	var leaf_textures = []
	for k in range(4):
		var leaf_size = 48
		var leaf_noise = FastNoiseLite.new()
		leaf_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		leaf_noise.frequency = 0.12 + k * 0.02
		leaf_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
		leaf_noise.fractal_octaves = 3
		leaf_noise.fractal_gain = 0.45

		var leaf_img = Image.create(leaf_size, leaf_size, false, Image.FORMAT_RGBA8)
		for lx in range(leaf_size):
			for ly in range(leaf_size):
				var dx = (lx - leaf_size / 2.0) / float(leaf_size / 2.0)
				var dy = (ly - leaf_size / 2.0) / float(leaf_size / 2.0)
				var dist = sqrt(dx * dx + dy * dy)
				if dist > 1.0:
					leaf_img.set_pixel(lx, ly, Color(0, 0, 0, 0))
					continue

				var n = (leaf_noise.get_noise_2d(lx, ly) + 1.0) * 0.5
				if n < 0.35:
					leaf_img.set_pixel(lx, ly, Color(0, 0, 0, 0))
					continue

				# vary brightness and saturation around bush_color
				var brightness = lerp(0.4, 1.4, n)
				var sat_shift = lerp(0.7, 1.3, rng.randf())
				var r = clamp(bush_color.r * brightness * sat_shift, 0.0, 1.0)
				var g = clamp(bush_color.g * brightness, 0.0, 1.0)
				var b = clamp(bush_color.b * brightness / sat_shift, 0.0, 1.0)
				leaf_img.set_pixel(lx, ly, Color(r, g, b, 1.0))

		var tex = ImageTexture.create_from_image(leaf_img)
		leaf_textures.append(tex)

	# --- Shared mesh properties ---
	var quad = QuadMesh.new()
	quad.size = Vector2(2, 2)

	for i in range(500):
		var x = rng.randi_range(0, size - 1)
		var y = rng.randi_range(0, size - 1)
		var t = FNL.get_pixel(x, y).r
		if t < 0.35 or t >= 0.6:
			continue

		var h = get_FNL_Height(x, y, FNL) + amplitude * 0.05  # corrected to sit just above surface

		var bush_root = Node3D.new()
		bush_root.position = Vector3(x * spacing, h, y * spacing)
		var s = rng.randf_range(0.8, 1.8)
		bush_root.scale = Vector3(s, s, s)

		var leaf_tex = leaf_textures[rng.randi_range(0, leaf_textures.size() - 1)]
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = leaf_tex
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.flags_transparent = true
		mat.alpha_scissor_threshold = 0.1
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

		for j in range(16):
			var leaf = MeshInstance3D.new()
			leaf.mesh = quad
			leaf.material_override = mat
			leaf.rotation.y = j * (TAU / 16.0)
			bush_root.add_child(leaf)

		add_child(bush_root)
