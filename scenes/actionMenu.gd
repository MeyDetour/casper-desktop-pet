extends Control # Ou Panel, VBoxContainer selon le type de ton ActionMenu

# On crée un signal pour prévenir le reste du jeu que le menu a changé d'état
signal menu_visibilite_change(est_visible: bool) 
@onready var fantome = %Area2D

func _ready() -> void:
	# Le menu se connecte directement à ses propres boutons enfants
	$VBoxContainer/Cacher.pressed.connect(_on_Cacher_pressed)
	$VBoxContainer/Minijeux.pressed.connect(_on_Minijeux_pressed)

func basculer_menu() -> void:
	visible = not visible
	menu_visibilite_change.emit(visible)

func _on_Cacher_pressed() -> void:
	print("[ACTION] Bouton 'Cacher' pressé !") 
	hide()
	
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var window = get_window()
	var rng = RandomNumberGenerator.new()
	var my_random_number = rng.randf_range(0.0,1.0)
	print(my_random_number)
		 
	if my_random_number > 0.5 :
		fantome.setToLeft() 
		fantome.flip_to_right()
		fantome.rotation(0)
	else :
		fantome.setToRight()
		fantome.rotation(0) 
		fantome.flip_to_left()
	window.position.y =( usable_rect.end.y * my_random_number) - get_parent().decalage_y_top_a_cause_du_menu
	get_parent().mode="hide"
	fantome.to_hide_mode()
	menu_visibilite_change.emit(true)

func _on_Minijeux_pressed() -> void:
	print("[ACTION] Bouton 'Minijeux' pressé !")
	hide() 
	menu_visibilite_change.emit(false)
