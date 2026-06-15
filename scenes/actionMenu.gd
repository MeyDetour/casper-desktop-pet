extends Control # Ou Panel, VBoxContainer selon le type de ton ActionMenu

# On crée un signal pour prévenir le reste du jeu que le menu a changé d'état
signal menu_visibilite_change(est_visible: bool) 

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
	var window = get_window()
	window.position.x = 0 - get_parent().decalage_X_a_cause_de_la_box_de_casper
	get_parent().immobilise = true
	menu_visibilite_change.emit(false)

func _on_Minijeux_pressed() -> void:
	print("[ACTION] Bouton 'Minijeux' pressé !")
	hide() 
	menu_visibilite_change.emit(false)
