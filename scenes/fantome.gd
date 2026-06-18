extends Area2D
 
# Dans fantome.gd
@onready var menu = $"../ActionMenu" 
@onready var notes = %InterfaceNotes
@onready var todo = %TodoList
@onready var timer_sommeil = %TimerSommeil
var move_speed = 2
var direction = Vector2(1,0)
var is_dragging = false
var drag_offset = Vector2i()
var est_en_train_de_somnoler = false
var vertical_velocity = 0.0

var usable_rect = DisplayServer.screen_get_usable_rect()
var is_waiting = false
var click_position_start = Vector2()
var est_endormi = false

func _ready() -> void:
	timer_sommeil.timeout.connect(_on_timer_sommeil_timeout)
	
func _process(delta: float) -> void:
	
	var window = get_window() 
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var ground_y = usable_rect.end.y - window.size.y + get_parent().fantome_gap_box - 20
	
	#print("mode :" +str(get_parent().mode))
	#print("immbolie :" +str(get_parent().immobilise))
	#print("dragging :" + str(is_dragging))
	# CAS 1 : fantome dragger 
	if is_dragging :
		var global_mouse_pos = DisplayServer.mouse_get_position()
		 
		reveiller_fantome()
		if get_parent().mode == "free" : 
			get_parent().immobilise = false
			window.position = global_mouse_pos - drag_offset
			vertical_velocity = 0.0 
			$AnimatedSprite2D.play("when dragging")
			
		elif get_parent().mode == "hide" : 
			
			var y = global_mouse_pos[1]  
			var x = global_mouse_pos[0] 
			 
			# si la souris est en haut
			if  y < (usable_rect.end.y /5 ) :
				setToTopScreen()
				get_window().position.x = x - get_parent().fantome_gap_box - get_parent().decalage_hit_box
				$AnimatedSprite2D.play("hide-top-screen-mooving")
				
			# souris à gauche
			elif x < usable_rect.end.x / 2    :
				setToLeft()  
				rotation(0)
				$AnimatedSprite2D.play('hide-mooving')
				$AnimatedSprite2D.flip_v = false
				flip_to_right()
				get_window().position.y = y - get_parent().decalage_y_top_a_cause_du_menu - get_parent().decalage_hit_box
			elif usable_rect.end.x / 2  < x  :
				setToRight() 
				rotation(0) 
				$AnimatedSprite2D.play('hide-mooving')
				$AnimatedSprite2D.flip_v = false
				flip_to_left()
				get_window().position.y = y - get_parent().decalage_y_top_a_cause_du_menu - get_parent().decalage_hit_box
	
	elif est_endormi :
		
		var move_vector = Vector2i(direction * move_speed * 0.3)
		window.position += move_vector
							
	elif est_endormi or get_parent().immobilise:
		
		return
		
	else:
		if get_parent().mode =="free" : 
		
			# CAS 2 : Fantome en l'air (Chute libre)
			if window.position.y < ground_y  :
				vertical_velocity += 0.2 * delta * 60 
				
				var fall_vector = Vector2i(direction.x * (move_speed * 0.5), vertical_velocity)
				window.position += fall_vector
				
				if window.position.y >= ground_y:
					print("[CHUTE] Atterrissage au sol détecté ! ground_y = ", ground_y)
					window.position.y = ground_y
					vertical_velocity = 0.0
					$AnimatedSprite2D.play("walking right")
				else:
					$AnimatedSprite2D.play("falling")
					
			# CAS 3 : fantome au sol        
			else: 
				if not is_waiting :
					var move_vector = Vector2i(direction * move_speed)
					if est_en_train_de_somnoler : 
						move_vector = Vector2i(direction * move_speed * 0.5)
					window.position += move_vector
					if not est_en_train_de_somnoler :
						$AnimatedSprite2D.play("walking right")
				 
				# Détection du mur DROIT
				if window.position.x + window.size.x - get_parent().fantome_gap_box > usable_rect.end.x:
					if not is_waiting:
						print("[MUR DROIT] Choc détecté ! Début de l'attente de 2s.")
						is_waiting = true
						$AnimatedSprite2D.play("wall")
						await get_tree().create_timer(2.0).timeout
						direction.x = -1
						$AnimatedSprite2D.flip_h = true
						is_waiting = false
						print("[MUR DROIT] Attente terminée. Fait demi-tour vers la GAUCHE.")
						
				# Détection du mur GAUCHE
				elif window.position.x + get_parent().fantome_gap_box < usable_rect.position.x:
					if not is_waiting:
						print("[MUR GAUCHE] Choc détecté ! Début de l'attente de 2s.")
						is_waiting = true
						$AnimatedSprite2D.play("wall")
						await get_tree().create_timer(2.0).timeout
						direction.x = 1
						$AnimatedSprite2D.flip_h = false
						is_waiting = false
						print("[MUR GAUCHE] Attente terminée. Fait demi-tour vers la DROITE.")
						
						
func _on_timer_sommeil_timeout() -> void:
	
	if get_parent().mode == "free" and not is_dragging:
			
		$AnimatedSprite2D.play('sommenole')
		est_en_train_de_somnoler = true
		print("[SOMMEIL] Casper commence à somnoler...")
		
		await get_tree().create_timer(8).timeout
		
		est_en_train_de_somnoler = false
		est_endormi = true
		get_parent().immobilise = true
		$AnimatedSprite2D.play('fall-sleeping')
		print("[SOMMEIL] Le fantôme s'est endormi de fatigue zZZz")
		
			
func reveiller_fantome() -> void:
	
	timer_sommeil.start()
	if est_endormi or est_en_train_de_somnoler:
		est_endormi = false
		est_en_train_de_somnoler = false
		get_parent().immobilise = false  
		print("[SOMMEIL] Le fantôme se réveille !")
	
func retourner_horizontalement() -> void:
	$AnimatedSprite2D.flip_h = true 
	
func flip_to_right() -> void:
	$AnimatedSprite2D.flip_h = false 
	
func flip_to_left() -> void:
	$AnimatedSprite2D.flip_h = true 
	
func setToLeft() -> void :
	get_window().position.x = 0 - get_parent().fantome_gap_box
	
func setToRight() -> void :
	get_window().position.x = usable_rect.end.x - get_window().size.x + get_parent().fantome_gap_box	

func setToTopScreen() -> void : 
	get_window().position.y = 0 - get_parent().decalage_y_top_a_cause_du_menu

func setToBottomScreen() -> void : 
	get_window().position.y = 0 - get_parent().fantome_gap_box

func headAtBottom() -> void : 
	return

func est_a_gauche() -> bool:
	return not  $AnimatedSprite2D.flip_h

func est_a_droite() -> bool:
	return  $AnimatedSprite2D.flip_h

func rotation(angle:int)->void :
		$AnimatedSprite2D.rotation_degrees = angle

func gerer_clic_simple() -> void:
	
	print("click simple")
	
	reveiller_fantome()
	
	if get_parent().mode =="hide":
		return
		
	if get_parent().mode=="note" || get_parent().mode=="todo"  :
		notes.hide()
		todo.hide()
		get_parent().mode = "free"
		get_parent().immobilise =false
		return
		
	menu.visible = not menu.visible
	get_parent().immobilise = menu.visible
	if menu.visible : 
		$AnimatedSprite2D.play('idle')
	else :
		$AnimatedSprite2D.play("walking right")
	print ("click simple executed")

func change_dragging(choice:bool):
	is_dragging = choice
	
func to_hide_mode() -> void:
	$AnimatedSprite2D.play("hide")
	print("fantome hide !")
	
func _input(event: InputEvent) -> void:
	
	var window = get_window()
	var ground_y = usable_rect.end.y - window.size.y + get_parent().fantome_gap_box - 20
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		print("DOBULE CLICK")
		is_dragging = false
		if get_parent().mode =="hide":
			get_parent().mode = "free"
			get_parent().immobilise = false
			return
		if (get_parent().mode=="free" or get_parent().mode=="note" or get_parent().mode=="todo" ) and   window.position.y - 200 < ground_y    :
			print('clic simple sur le fantome !')
			gerer_clic_simple()
			
		return
		
	if  event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("[CLIC] Bouton de souris enfoncé sur la CollisionShape.")
		is_dragging = true
		# permet de garder le fantome sous la souris
		drag_offset = DisplayServer.mouse_get_position() - get_window().position
		click_position_start = DisplayServer.mouse_get_position()
		return
	
	if event is InputEventMouseButton and  event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_dragging:
				 
				# faire tomber le fantome
				var current_mouse_pos = DisplayServer.mouse_get_position()
				var distance_parcourue = click_position_start.distance_to(current_mouse_pos)
				print("[SOURIS] Bouton relâché. Distance parcourue pendant le clic = ", distance_parcourue, " pixels.")
				
				is_dragging = false
				
				if distance_parcourue > 5 :
					
					if get_parent().mode =="hide" and window.position.y <= 0: 
						$AnimatedSprite2D.play("hide-top-screen")
					elif get_parent().mode =="hide" : 
						$AnimatedSprite2D.play("hide")
					print("[SOURIS] Le fantôme a été lâché après un glissement (Drag & Drop). Il commence à tomber.")
