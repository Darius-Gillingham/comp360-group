extends Node2D

@onready var tile_map: TileMap = $TileMap 

#Set up width, height and FastNoiseLight
const width = 1000 
const height = 1000
var noise  = FastNoiseLite.new()

func _ready():
	generate_world()


func generate_world():
	#Use built in random number generator
	var rng = RandomNumberGenerator.new()
	
	# Create list for tile types	
	var tiles_list: Array[Vector2i] = []
	
	# Add the tiles from the tile_map
	tiles_list.append(TileDictonary.WATER)
	tiles_list.append(TileDictonary.SAND)
	tiles_list.append(TileDictonary.GRASS)
	tiles_list.append(TileDictonary.DARK_GRASS)
	tiles_list.append(TileDictonary.ROCK)
	tiles_list.append(TileDictonary.DARK_ROCK)
	
	rng.randomize()
	noise.seed = rng.randi_range(0, 500)
	
	#FastNoiseLight.TYPE_SIMPLEX creates the islands and rivers look to the map
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	#Fractal_octaves creates the circular shapes to the islands
	noise.fractal_octaves = tiles_list.size()
	noise.fractal_gain = 0.0
	
	#For loop to go iterate the width and height of the screen
	for x in range(width):
		for y in range(height):
			#generates the noise for the x and y position
			var abs_noise = abs(noise.get_noise_2d(x,y))
		
			var tiles_to_place = floori(abs_noise * tiles_list.size())
			tile_map.set_cell(0, Vector2i(x, y), 0, tiles_list[tiles_to_place])
			
