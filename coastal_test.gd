extends Node2D


func _ready():
	var img = generate_Gradient(400)
	var sprite = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)

func generate_FNL_Noise(size): #Generates the noise map, this can be heavily tweaked to get ideal look for water or mountians etc
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = 1319
	noise.frequency = 0.01
	
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 1.5
	noise.fractal_gain = 1
	noise.fractal_weighted_strength = 25
	
	var img =  noise.get_image(size,size,true, false, false)
	save_png(img, "res://debug_noise.png")
	
	return img
	
func generate_Coastal_Deform_Noise(size):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = 1319
	noise.frequency = 0.01
	
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 1.5
	noise.fractal_gain = 1
	noise.fractal_weighted_strength = 1
	
	var img =  noise.get_image(size,size,true, false, false)
	save_png(img, "res://debug_noise.png")
	
	return img
	
func generate_Gradient(size): #Generates the noise map, this can be heavily tweaked to get ideal look for water or mountians etc
	var grad = Gradient.new()
	
	#grad.set_color(0, Color.GREEN)
	#grad.set_color(1, Color.BLUE_VIOLET)
	
	grad.add_point(0.47, Color.BLACK)
	grad.add_point(0.53, Color.WHITE)
	
	var grad_text = GradientTexture2D.new()
	grad_text.gradient = grad
	grad_text.height = size
	grad_text.width = size

	var img =  grad_text.get_image()
	save_png(img, "res://debug_noise.png")
	
	var noise = generate_FNL_Noise(size)
	for x in range(size):
		for y in range(size):
			var color = noise.get_pixel(x,y) + img.get_pixel(x,y)
			#var color = noise.get_pixel(x,y) * noise.get_pixel(x,y) 
			noise.set_pixel(x,y,color)
			
	var deform_noise = generate_Coastal_Deform_Noise(size)
	for x in range(size):
		for y in range(size):
			var grey_amount = deform_noise.get_pixel(x,y).r
			grey_amount *= 0.3
			var color = noise.get_pixel(x,y) - Color(grey_amount, grey_amount, grey_amount, 1)
			#print(color)
			#var color = noise.get_pixel(x,y) * noise.get_pixel(x,y) 
			noise.set_pixel(x,y,color)
	
	return noise
	
func save_png(img, path): #saves FNL png for comparison after
	# Save PNG for debugging (res:// saves into your project folder)
	var save_path = path
	var err = img.save_png(save_path)
	if err == OK:
		print("Noise saved to ", save_path)
	else:
		print("Error saving noise image: ", err)
