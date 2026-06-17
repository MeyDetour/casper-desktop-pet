extends Node2D

@onready var fantome = $Area2D
@onready var menu = $ActionMenu
@onready var notes = $InterfaceNotes
 
var compteur_clics = 0
var immobilise: bool = false
var mode:String = "free"

var decalage_y_top_a_cause_du_menu = 165
var decalage_hit_box = 50
var fantome_gap_box = 40
 
func _ready() -> void:
	print("--- INITIALISATION DE LA FENÊTRE ---")
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = false
	menu.hide()
	notes.hide()
	
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var target_y = usable_rect.end.y - window.size.y + fantome_gap_box
	window.position = Vector2i(0, target_y)
	print("Fenêtre configurée. Position initiale au sol : ", window.position)
	  
	
	
