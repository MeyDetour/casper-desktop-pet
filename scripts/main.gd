extends Node2D

var move_speed = 2
var direction = Vector2(1,0)

var is_dragging = false
var drag_offset = Vector2i()
 
var gravity = 0.2      
var vertical_velocity = 0.0 

var is_waiting = false
var click_position_start = Vector2()
var compteur_clics = 0
var decalage_y_a_cause_de_la_box_de_casper = 0
var decalage_X_a_cause_de_la_box_de_casper = 100

var menuShown = false
func _ready() -> void:
	print("--- INITIALISATION DU FANTÔME ---")
	var window = get_window()
	var window_id = window.get_window_id()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = false
	$ActionMenu.hide()
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var target_y = usable_rect.end.y - window.size.y + decalage_y_a_cause_de_la_box_de_casper
	window.position = Vector2i(0, target_y)
	print("Fenêtre configurée. Position initiale au sol : ", window.position)
	$ActionMenu/VBoxContainer/Cacher.pressed.connect(_on_Cacher_pressed)
	$ActionMenu/VBoxContainer/Minijeux.pressed.connect(_on_Minijeux_pressed)

func _process(delta:float):
	var window = get_window() 
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var ground_y = usable_rect.end.y - window.size.y + decalage_y_a_cause_de_la_box_de_casper
	
	# CAS 1 : fantome dragger
	if is_dragging:
		var global_mouse_pos = DisplayServer.mouse_get_position()
		window.position = global_mouse_pos - drag_offset
		vertical_velocity = 0.0 
		$Area2D/AnimatedSprite2D.play("when dragging")
	elif menuShown: 
		$Area2D/AnimatedSprite2D.play("idle") # Tu peux mettre une animation "idle" (statique) si tu en as une !
			
	else:
		# CAS 2 : Fantome en l'air (Chute libre)
		if window.position.y < ground_y:
			vertical_velocity += gravity * delta * 60 
			
			var fall_vector = Vector2i(direction.x * (move_speed * 0.5), vertical_velocity)
			window.position += fall_vector
			
			if window.position.y >= ground_y:
				print("[CHUTE] Atterrissage au sol détecté ! ground_y = ", ground_y)
				window.position.y = ground_y
				vertical_velocity = 0.0
				$Area2D/AnimatedSprite2D.play("walking right")
			else:
				$Area2D/AnimatedSprite2D.play("falling")
				# Décommente la ligne dessous si tu veux voir la vitesse augmenter pendant la chute :
				# print("[CHUTE] Le fantôme tombe... Vitesse verticale = ", vertical_velocity)
				
		# CAS 3 : fantome au sol        
		else: 
			if not is_waiting :
				var move_vector = Vector2i(direction * move_speed)
				window.position += move_vector
				$Area2D/AnimatedSprite2D.play("walking right")
			 
			# Détection du mur DROIT
			if window.position.x + window.size.x - decalage_X_a_cause_de_la_box_de_casper > usable_rect.end.x:
				if not is_waiting:
					print("[MUR DROIT] Choc détecté ! Début de l'attente de 2s.")
					is_waiting = true
					$Area2D/AnimatedSprite2D.play("wall")
					await get_tree().create_timer(2.0).timeout
					direction.x = -1
					$Area2D/AnimatedSprite2D.flip_h = true
					is_waiting = false
					print("[MUR DROIT] Attente terminée. Fait demi-tour vers la GAUCHE.")
					
			# Détection du mur GAUCHE
			elif window.position.x + decalage_X_a_cause_de_la_box_de_casper < usable_rect.position.x:
				if not is_waiting:
					print("[MUR GAUCHE] Choc détecté ! Début de l'attente de 2s.")
					is_waiting = true
					$Area2D/AnimatedSprite2D.play("wall")
					await get_tree().create_timer(2.0).timeout
					direction.x = 1
					$Area2D/AnimatedSprite2D.flip_h = false
					is_waiting = false
					print("[MUR GAUCHE] Attente terminée. Fait demi-tour vers la DROITE.")

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("[CLIC] Bouton de souris enfoncé sur la CollisionShape.")
			is_dragging = true
			drag_offset = DisplayServer.mouse_get_position() - get_window().position
			click_position_start = DisplayServer.mouse_get_position()

# RELÂCHER LE FANTÔME N'IMPORTE OÙ
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			
			if is_dragging:
				var current_mouse_pos = DisplayServer.mouse_get_position()
				var distance_parcourue = click_position_start.distance_to(current_mouse_pos)
				
				print("[SOURIS] Bouton relâché. Distance parcourue pendant le clic = ", distance_parcourue, " pixels.")
				is_dragging = false 
				
				if distance_parcourue < 5:
					print("[SOURIS] Distance très courte (< 5px) -> Traité comme un clic statique.")
					gerer_mecanique_clics()
				else:
					print("[SOURIS] Le fantôme a été lâché après un glissement (Drag & Drop). Il commence à tomber.")
					
func gerer_mecanique_clics() -> void: 
	var window = get_window()
	# Si le menu est CACHÉ, on l'affiche et on bloque le mouvement
	if not $ActionMenu.visible:
		print("[MÉCANIQUE CLIC] Le menu était masqué -> APPARATION DU MENU")
		$ActionMenu.show() 
		menuShown = true # CORRECTION : On passe à true pour figer le fantôme !
	
	# Si le menu était déjà VISIBLE, on le cache et il reprend sa marche
	else:
		print("[MÉCANIQUE CLIC] Le menu était affiché -> DISPARITION DU MENU")
		$ActionMenu.hide() 
		menuShown = false # CORRECTION : On repasse à false pour qu'il recommence à marcher
		
func _on_Cacher_pressed() -> void:
	print("[ACTION] Bouton 1 pressé : Action 'Cacher' lancée !") 
	# Optionnel : Fermer le menu après avoir cliqué sur une action
	$ActionMenu.hide()
	menuShown = false
	compteur_clics = 0

func _on_Minijeux_pressed() -> void:
	print("[ACTION] Bouton 2 pressé : Action 'Minijeux' lancée !")
	$ActionMenu.hide() 
	
	menuShown = false
	compteur_clics = 0
