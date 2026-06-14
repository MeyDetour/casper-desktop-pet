extends Node2D

var move_speed = 2
var direction = Vector2(1,0)

var is_dragging = false
var drag_offset = Vector2i()

var gravity = 0.2      
var vertical_velocity = 0.0 

var is_waiting = false

func _ready() -> void:
	var window = get_window()
	var window_id = window.get_window_id()
	
	get_viewport().transparent_bg = true
	window.transparent = true
	window.borderless = true
	window.always_on_top = true
	window.unresizable = false
	
	get_viewport().showInTaskbar = false
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var target_y = usable_rect.end.y - window.size.y
	window.position = Vector2i(0, target_y)

func _process(delta:float):
	var window = get_window() 
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var ground_y = usable_rect.end.y - window.size.y 
	
	# CAS 1 : fantome dragger
	if is_dragging:
		var global_mouse_pos = DisplayServer.mouse_get_position()
		window.position = global_mouse_pos - drag_offset
		vertical_velocity = 0.0 
		$Area2D/AnimatedSprite2D.play("when dragging")
		
	else:
		# CAS 2 : Fantome en l'air (Chute libre)
		if window.position.y < ground_y:
			vertical_velocity += gravity * delta * 60 
			
			var fall_vector = Vector2i(direction.x * (move_speed * 0.5), vertical_velocity)
			window.position += fall_vector
			
			if window.position.y >= ground_y:
				window.position.y = ground_y
				vertical_velocity = 0.0
				$Area2D/AnimatedSprite2D.play("walking right")
			else:
				$Area2D/AnimatedSprite2D.play("falling")
				
		# CAS 3 : fantome au sol        
		else: 
			if not is_waiting:
				var move_vector = Vector2i(direction * move_speed)
				window.position += move_vector
				$Area2D/AnimatedSprite2D.play("walking right")
			 
			 
			if window.position.x + window.size.x  - 100> usable_rect.end.x:
				is_waiting = true
				$Area2D/AnimatedSprite2D.play("wall")
				await get_tree().create_timer(2.0).timeout
				direction.x = -1
				$Area2D/AnimatedSprite2D.flip_h = true
				is_waiting = false
			elif window.position.x +100 < usable_rect.position.x:
				is_waiting = true
				$Area2D/AnimatedSprite2D.play("wall")
				await get_tree().create_timer(2.0).timeout
				direction.x = 1
				$Area2D/AnimatedSprite2D.flip_h = false
				is_waiting = false

# DÉTECTION DU CLIC SUR LE FANTÔME
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_dragging = true
			drag_offset = DisplayServer.mouse_get_position() - get_window().position

# RELÂCHER LE FANTÔME N'IMPORTE OÙ
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false
