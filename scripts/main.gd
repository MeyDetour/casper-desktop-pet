extends Node2D

var move_speed = 2
var direction = Vector2(1,0)

var is_dragging = false
var drag_offset = Vector2i()

var gravity = 0.2      
var vertical_velocity = 0.0

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
	
func _process(delta:float):
	var window = get_window() 
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var ground_y = usable_rect.end.y - window.size.y 
	
	# CAS 1 : fantome dragger
	if is_dragging:
		# deplacer à la position de la souris
		var global_mouse_pos = DisplayServer.mouse_get_position()
		window.position = global_mouse_pos - drag_offset
		# reinitialisation de la vitesse
		vertical_velocity = 0.0 # On réinitialise la vitesse de chute pendant qu'on le tient
		$Area2D/AnimatedSprite2D.play("when dragging")
	else:
		# CAS 2 Fantome en l'air
		if window.position.y < ground_y:
			# On applique la gravité à la vitesse verticale
			vertical_velocity += gravity * delta * 60 # Ajusté pour le framerate
			
			# Déplacement en chute (on garde un léger mouvement horizontal s'il avançait)
			var fall_vector = Vector2i(direction.x * (move_speed * 0.5), vertical_velocity)
			window.position += fall_vector
			$Area2D/AnimatedSprite2D.play("falling")
			
			# Sécurité : Si le fantôme dépasse le sol à cause de la vitesse, on le recale pile sur le sol
			if window.position.y >= ground_y:
				window.position.y = ground_y
				vertical_velocity = 0.0
				
		# CAS 3 : fantome au sol		
		else : 
			# Comportement de déplacement automatique d'origine
			var move_vector = Vector2i(direction * move_speed)
			window.position += move_vector
			$Area2D/AnimatedSprite2D.play("walking right")
			 
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
