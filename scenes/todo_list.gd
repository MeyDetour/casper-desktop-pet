extends Control

@onready var liste_todo = $VBoxContainer/ListTodo
@onready var zone_texte = $VBoxContainer/TextEdit

const DOSSIER_NOTES = "user://todo/"
# Cette variable va stocker le nom du fichier .txt actuellement ouvert
var todo_nom = ""

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(DOSSIER_NOTES):
		DirAccess.make_dir_absolute(DOSSIER_NOTES)
		
	$VBoxContainer/HBoxContainer/BoutonSauvegarder.pressed.connect(sauvegarder_note_actuelle)
	$VBoxContainer/HBoxContainer/BoutonNouveau.pressed.connect(creer_nouvelle_note)
	$VBoxContainer/HBoxContainer/BoutonSupp.pressed.connect(supprimer)
	
	# /!\ IMPORTANT : On connecte le clic sur la liste pour charger la note
	liste_todo.item_selected.connect(_on_note_selectionnee)
	
	rafraichir_liste_de_notes()

# 1. Liste des notes (Ta version corrigée, qui est au top !)
func rafraichir_liste_de_notes() -> void:
	liste_todo.clear()
	show()
	$VBoxContainer/TextEdit.hide()
	$VBoxContainer/HBoxContainer/BoutonNouveau.show()
	$VBoxContainer/HBoxContainer/BoutonSupp.hide()
	$VBoxContainer/HBoxContainer/BoutonSauvegarder.hide()
	
	var dir = DirAccess.open(DOSSIER_NOTES)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".txt"): 
				var chemin_complet = DOSSIER_NOTES + "/" + file_name
				var fichier = FileAccess.open(chemin_complet, FileAccess.READ)
				
				if fichier:
					var contenu = fichier.get_as_text().strip_edges() 
					if contenu.is_empty():
						contenu = "(Note vide)"
					if contenu.length() > 50:
						contenu = contenu.left(50) + "..."
					
					# On ajoute l'item dans la liste
					var index = liste_todo.add_item(contenu)
					# ASTUCE : On cache le vrai nom du fichier dans l'item pour pouvoir le retrouver après
					liste_todo.set_item_metadata(index, file_name)
					
					fichier.close()
					
			file_name = dir.get_next()
		dir.list_dir_end()

# 2. Charger une note quand on clique dessus dans la liste
func _on_note_selectionnee(index: int) -> void:
	# On récupère le vrai nom du fichier qu'on avait caché dans les métadonnées
	todo_nom = liste_todo.get_item_metadata(index)
	
	var fichier = FileAccess.open(DOSSIER_NOTES + todo_nom, FileAccess.READ)
	if fichier:
		
		$VBoxContainer/HBoxContainer/BoutonSauvegarder.show()
		$VBoxContainer/HBoxContainer/BoutonSupp.show()
		$VBoxContainer/HBoxContainer/BoutonNouveau.hide()
		$VBoxContainer/TextEdit.show()
		$VBoxContainer/ListTodo.hide()
		zone_texte.text = fichier.get_as_text()
		fichier.close()

# 3. Sauvegarder (Modification OU Création)
func sauvegarder_note_actuelle() -> void:
	# Si la zone de texte est complètement vide, on évite de sauvegarder du vent
	if zone_texte.text.strip_edges().is_empty():
		return

	# Si c'est une NOUVELLE note (pas encore de nom), on lui génère son nom unique
	if todo_nom == "":
		todo_nom = "Todo_" + str(Time.get_unix_time_from_system()) + ".txt"
		
	var fichier = FileAccess.open(DOSSIER_NOTES + todo_nom, FileAccess.WRITE)
	if fichier:
		fichier.store_string(zone_texte.text)
		fichier.close()
		print("Sauvegardé avec succès : ", todo_nom)
		
		$VBoxContainer/HBoxContainer/BoutonSauvegarder.hide()
		$VBoxContainer/HBoxContainer/BoutonSupp.hide()
		$VBoxContainer/HBoxContainer/BoutonNouveau.hide()
		$VBoxContainer/TextEdit.hide()
		$VBoxContainer/ListTodo.show()
		rafraichir_liste_de_notes()

# 4. Bouton "Nouveau"
func creer_nouvelle_note() -> void:
	zone_texte.text = "" 
	liste_todo.deselect_all()
	$VBoxContainer/HBoxContainer/BoutonSauvegarder.show()
	$VBoxContainer/HBoxContainer/BoutonSupp.show()
	$VBoxContainer/TextEdit.show()
	$VBoxContainer/HBoxContainer/BoutonNouveau.hide()
	$VBoxContainer/ListTodo.hide()
	
 
func supprimer() -> void:  
	var chemin_complet = DOSSIER_NOTES + todo_nom 
	if FileAccess.file_exists(chemin_complet):
		var erreur = DirAccess.remove_absolute(chemin_complet)
		if erreur == OK:
			print("Note supprimée avec succès : ", todo_nom)
		else:
			print("Erreur lors de la suppression du fichier : ", erreur)
			 
	todo_nom = "" 
	zone_texte.text = ""
	$VBoxContainer/ListTodo.show()
	rafraichir_liste_de_notes()
