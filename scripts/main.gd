extends Node2D

@onready var fantome = $Area2D
@onready var menu = $ActionMenu
 
var compteur_clics = 0
var immobilise: bool = false
var mode:String = "free"

var decalage_y_a_cause_de_la_box_de_casper = 0
var decalage_X_a_cause_de_la_box_de_casper = 55
var decalage_X_en_mode_fantome = 80
func _ready() -> void:
	print("--- INITIALISATION DE LA FENÊTRE ---")
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = false
	menu.hide()
	
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var target_y = usable_rect.end.y - window.size.y + decalage_y_a_cause_de_la_box_de_casper
	window.position = Vector2i(0, target_y)
	print("Fenêtre configurée. Position initiale au sol : ", window.position)
	 
	# CORRECTION : On connecte le clic du fantôme directement à la fonction du menu
	fantome.fantome_clique.connect(menu.basculer_menu)	
	
	# Quand le menu change d'état, on fige ou libère le fantôme
	menu.menu_visibilite_change.connect(func(est_visible): immobilise = est_visible)
	
	
