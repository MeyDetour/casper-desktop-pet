extends Control # Ou Panel, VBoxContainer selon le type de ton ActionMenu

# On crée un signal pour prévenir le reste du jeu que le menu a changé d'état
 
@onready var fantome = %Area2D
@onready var notes = %InterfaceNotes
func _ready() -> void:
	# Le menu se connecte directement à ses propres boutons enfants
	$VBoxContainer/Cacher.pressed.connect(_on_Cacher_pressed)
	$VBoxContainer/Notes.pressed.connect(_on_Notes_pressed)
 
func stop_fantome() : 
	get_viewport().set_input_as_handled()
	fantome.change_dragging(false)
	hide()

func _on_Cacher_pressed() -> void:
	
	print("[ACTION] Bouton 'Cacher' pressé !") 
	stop_fantome()
	
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var window = get_window()
	var rng = RandomNumberGenerator.new()
	var my_random_number = rng.randf_range(0.0,1.0)
	 
	fantome.to_hide_mode() 
	get_parent().mode="hide"
	get_parent().immobilise = true
	if my_random_number > 0.5 :
		fantome.setToLeft() 
		fantome.flip_to_right()
		fantome.rotation(0)
	else :
		fantome.setToRight()
		fantome.rotation(0) 
		fantome.flip_to_left()
	window.position.y =( usable_rect.end.y * my_random_number) - get_parent().decalage_y_top_a_cause_du_menu
	 
	print("Fantome caché !")
	 

func _on_Notes_pressed() -> void:
	print("[ACTION] Bouton 'Notes' pressé !")
	stop_fantome()
	get_parent().immobilise = true
	
	get_parent().mode="note"
	notes.rafraichir_liste_de_notes()
