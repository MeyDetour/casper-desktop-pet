extends Node2D

var move_speed = 2
var direction = Vector2(1,0)
var is_dragging = false
var drag_offset = Vector2i()
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
	 
	if is_dragging:
		var global_mouse_pos = DisplayServer.mouse_get_position()
		window.position = global_mouse_pos - drag_offset
	else:
		# Comportement de déplacement automatique d'origine
		var move_vector = Vector2i(direction * move_speed)
		window.position += move_vector
		
		var usable_rect = DisplayServer.screen_get_usable_rect()
		if window.position.x + window.size.x > usable_rect.end.x:
			direction.x = -1
			$Area2D/AnimatedSprite2D.flip_h = true
		elif window.position.x < usable_rect.position.x:
			direction.x = 1
			$Area2D/AnimatedSprite2D.flip_h = false
			
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# L'utilisateur a cliqué : on commence le drag
				is_dragging = true
				# On stocke la position globale de la souris par rapport à la position de la fenêtre
				# pour éviter que la fenêtre "saute" brusquement au moment du clic
				drag_offset = DisplayServer.mouse_get_position() - get_window().position
			else:
				# L'utilisateur a relâché le clic : on arrête le drag
				is_dragging = false
