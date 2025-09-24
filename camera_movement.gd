extends Node3D

@onready var camera = $Camera3D

var camera_move_speed = 3
var mouse_sensitivity = 0.005

func _input(event: InputEvent) -> void:
	
	# Mouse motion docs: https://docs.godotengine.org/en/4.4/classes/class_inputeventmousemotion.html
	# "is vs ==": https://www.reddit.com/r/godot/comments/rupe2i/gd_script_difference_between_is_and/
	# Rotation docs: https://docs.godotengine.org/en/latest/tutorials/3d/using_transforms.html
	if event is InputEventMouseMotion and event.get_pressure() > 0:
		camera.rotate(transform.basis.y, -event.relative.x * mouse_sensitivity)
		camera.rotate_object_local(transform.basis.x, -event.relative.y * mouse_sensitivity)
		
	# Deleted because this works smoother in _process
	#if event is InputEventKey:
		#if event.get_keycode() == KEY_A:
			#camera.translate(-transform.basis.x * camera_move_speed)
		#elif event.get_keycode() == KEY_D:
			#camera.translate(transform.basis.x * camera_move_speed)
			#
		#if event.get_keycode() == KEY_W:
			#camera.translate(transform.basis.y * camera_move_speed)
		#elif event.get_keycode() == KEY_S:
			#camera.translate(-transform.basis.y * camera_move_speed)
		
		

# Inspiration Source:
# (Bardo, 2024)
# https://forum.godotengine.org/t/how-can-i-move-and-rotate-an-isometric-camera-in-3d/51832/8
func _process(delta):
	# Camera movement works smoother in _process than _input 
	if Input.is_key_pressed(KEY_A):
		camera.translate(-transform.basis.x * camera_move_speed * delta)
	elif Input.is_key_pressed(KEY_D):
		camera.translate(transform.basis.x * camera_move_speed * delta)
		
	if Input.is_key_pressed(KEY_Q):
		camera.translate(transform.basis.y * camera_move_speed * delta)
	elif Input.is_key_pressed(KEY_E):
		camera.translate(-transform.basis.y * camera_move_speed * delta)
		
	if Input.is_key_pressed(KEY_S):
		camera.translate(transform.basis.z * camera_move_speed * delta)
	elif Input.is_key_pressed(KEY_W):
		camera.translate(-transform.basis.z * camera_move_speed * delta)
