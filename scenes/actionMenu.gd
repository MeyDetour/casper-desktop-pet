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
	if my_random_number > 0.5 :
		window.position.x = 0 - get_parent().decalage_X_en_mode_fantome
	else :
		window.position.x = usable_rect.end.x - window.size.x - get_parent().decalage_X_en_mode_fantome	
		fantome.retourner_horizontalement()
	window.position.y = usable_rect.end.y * my_random_number
	fantome.to_hide_mode()
	menu_visibilite_change.emit(true)

func _on_Minijeux_pressed() -> void:
	print("[ACTION] Bouton 'Minijeux' pressé !")
	hide() 
	menu_visibilite_change.emit(false)
