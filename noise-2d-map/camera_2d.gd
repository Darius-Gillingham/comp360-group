extends Camera2D

@export var max_offset: float = 500
@export var sensitivity: float = 1000.0

func _process(delta):
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Convert Vector2i to Vector2 by explicitly casting
	var viewport_center = Vector2(viewport_size) / 2.0
	var mouse_offset = Vector2(mouse_pos) - viewport_center
	
	var target_position = mouse_offset.normalized() * max_offset
	var lerp_factor = min(mouse_offset.length() / sensitivity, 1.0)
	
	position = lerp(Vector2.ZERO, target_position, lerp_factor)
