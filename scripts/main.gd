extends Node2D

var move_speed = 2
var direction = Vector2(1,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true
	window.borderless = true
	window.always_on_top = true
	window.unresizable = false
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var target_y = usable_rect.end.y - window.size.y
	window.position = Vector2i(0,target_y)
	
func _process(_delta):
	 
	var window = get_window()
	var move_vector = Vector2i(direction * move_speed)
	window.position += move_vector
	var usable_rect = DisplayServer.screen_get_usable_rect()
	if window.position.x + window.size.x > usable_rect.end.x :
		direction.x = -1
		$AnimatedSprite2D.flip_h = true
		
	elif window.position.x < usable_rect.position.x :
		direction.x = 1
		$AnimatedSprite2D.flip_h = false
