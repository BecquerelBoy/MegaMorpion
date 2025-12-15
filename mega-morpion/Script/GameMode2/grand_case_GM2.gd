extends Node2D

# Signaux pour communiquer avec la scène principale
signal petite_grille_gagnee(grande_case_num, winner)
signal petite_grille_nulle(grande_case_num)
signal case_jouee(grande_case_num, petite_case_num)

# Référence aux sprites de preview
@onready var blue_circle = $Assets/BlueCircle
@onready var red_cross = $Assets/RedCross
@onready var pentacle = $Assets/Pentacle
@onready var sun = $Assets/Sun
@onready var cadre_anim = $Assets/CadreAnim
@onready var grille_anim: AnimatedSprite2D = $Assets/GrilleAnim

# Scènes de symboles à instancier
var symbol_scenes = {
	"cross": preload("res://Scene/Symbol/croix.tscn"),
	"pentacle": preload("res://Scene/Symbol/pentacle.tscn"),
	"circle": preload("res://Scene/Symbol/rond.tscn"),
	"sun": preload("res://Scene/Symbol/soleil.tscn")
}

# Variables de jeu
var grid_state = {}  # Stocke l'état de chaque petite case
var shapes = []  # Tableau pour stocker les 9 petites cases
var is_playable = false  # Indique si cette grande case est jouable
var current_player = "cross"
var is_won = false  # Indique si cette grille est déjà gagnée
var grande_case_number = 0  # Numéro de cette grande case (1-9)
var preview_symbol = null  # Symbole de prévisualisation
var current_hovered_case = null  # Case actuellement survolée
var symbol_won_scale = 3

func _ready():
	# Déterminer le numéro de cette grande case
	var name_str = name  # ex: "GrandeCase3"
	grande_case_number = int(name_str.replace("GrandeCase", ""))
	
	# Cacher tous les sprites de preview
	blue_circle.visible = false
	red_cross.visible = false
	pentacle.visible = false
	sun.visible = false
	
	# Récupérer toutes les petites cases et connecter leurs signaux
	for i in range(1, 10):
		var case_node = get_node("ShapeCase/ShapePetiteCase" + str(i))
		shapes.append(case_node)
		grid_state[i] = null
		
		# S'assurer que l'Area2D peut recevoir les événements de souris
		case_node.input_pickable = true
		case_node.monitoring = true
		case_node.monitorable = true
		
		# Connecter les signaux de chaque Area2D
		case_node.input_event.connect(_on_case_clicked.bind(i))
		case_node.mouse_entered.connect(_on_case_mouse_entered.bind(i))
		case_node.mouse_exited.connect(_on_case_mouse_exited.bind(i))
	
	print("GrandeCase", grande_case_number, " initialisée avec ", shapes.size(), " petites cases")

func _on_case_clicked(_viewport, event, _shape_idx, case_number):
	# Vérifier si c'est un clic gauche, si la case est vide et si cette grille est jouable
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if grid_state[case_number] == null and is_playable and not is_won:
			place_symbol(case_number)

func _on_case_mouse_entered(case_number):
	# → Lancer l'animation de la grande case où l'adversaire devra jouer
	var main_scene = get_tree().get_root().get_node("Main")
	var grande_grille = main_scene.get_node("GrandeGrille")

	# Récupérer la prochaine grande case
	var target_case = grande_grille.get_node("GrandeCase" + str(case_number))

	print("Souris entrée dans case ", case_number, " de GrandeCase", grande_case_number)
	# Afficher l'aperçu seulement si la case est vide et jouable
	if grid_state[case_number] == null and is_playable and not is_won:
		current_hovered_case = case_number
		show_preview(case_number)
		# Afficher dans quelle grande case l'adversaire devra jouer
		print(">>> Si vous jouez ici, l'adversaire devra jouer dans la GrandeCase", case_number)
	else:
		print("Case non jouable : vide=", grid_state[case_number] == null, " playable=", is_playable, " won=", is_won)
		
	# Lancer l'animation seulement si la grande case n'est pas déjà gagnée
	if not target_case.is_won:
		target_case.cadre_anim.play("default")
		target_case.grille_anim.play("default")


func _on_case_mouse_exited(case_number):
	# → Arrêter l'animation de la grande case cible quand on quitte la case
	var main_scene = get_tree().get_root().get_node("Main")
	var grande_grille = main_scene.get_node("GrandeGrille")
	var target_case = grande_grille.get_node("GrandeCase" + str(case_number))
	
	print("Souris sortie de case ", case_number)
	# Cacher l'aperçu quand on sort de la case
	if current_hovered_case == case_number:
		current_hovered_case = null
		hide_preview()
	
	if not target_case.is_won and not target_case.is_playable:
		target_case.cadre_anim.stop()
		target_case.grille_anim.stop()

# Fonction pour déterminer quel symbole utiliser selon le personnage
func get_symbol_type_for_player(player: String) -> String:
	if player == "cross":
		# Joueur 1
		if Global.player1_character == "Chara0":
			return "cross"
		else:  # Chara1
			return "pentacle"
	else:
		# Joueur 2 (circle)
		if Global.player2_character == "Chara2":
			return "circle"
		else:  # Chara3
			return "sun"

# Fonction pour obtenir le sprite de preview correspondant
func get_preview_sprite_for_symbol(symbol_type: String) -> Sprite2D:
	match symbol_type:
		"cross":
			return red_cross
		"pentacle":
			return pentacle
		"circle":
			return blue_circle
		"sun":
			return sun
		_:
			return red_cross  # Par défaut

func show_preview(case_number):
	# Supprimer l'ancien aperçu s'il existe
	hide_preview()
	
	var case_node = shapes[case_number - 1]
	var cshape = case_node.get_node("CShape" + str(case_number))
	
	# Déterminer quel symbole afficher
	var symbol_type = get_symbol_type_for_player(current_player)
	var sprite_source = get_preview_sprite_for_symbol(symbol_type)
	
	# Créer un aperçu du sprite (duplication pour la preview)
	preview_symbol = sprite_source.duplicate()
	
	# Rendre le symbole semi-transparent pour l'aperçu
	preview_symbol.modulate = Color(1, 1, 1, 0.5)
	preview_symbol.visible = true
	preview_symbol.position = Vector2.ZERO
	
	cshape.add_child(preview_symbol)

func hide_preview():
	if preview_symbol != null:
		preview_symbol.queue_free()
		preview_symbol = null

func place_symbol(case_number):
	
	GameState.register_symbol(grande_case_number, case_number, current_player)

	# Cacher l'aperçu avant de placer le symbole définitif
	hide_preview()
	
	var case_node = shapes[case_number - 1]
	var cshape = case_node.get_node("CShape" + str(case_number))
	
	# Déterminer quel symbole instancier
	var symbol_type = get_symbol_type_for_player(current_player)
	
	# Instancier le nouveau symbole
	var new_symbol = symbol_scenes[symbol_type].instantiate()
	
	# Stocker l'état dans la grille
	grid_state[case_number] = current_player
	
	# Positionner et afficher le symbole (opacité normale)
	new_symbol.modulate = Color(1, 1, 1, 1)
	new_symbol.position = Vector2.ZERO
	
	cshape.add_child(new_symbol)
	
	# Émettre le signal que cette case a été jouée
	emit_signal("case_jouee", grande_case_number, case_number)
	
	# Vérifier s'il y a un gagnant dans cette petite grille
	check_winner()

func check_winner():
	# Combinaisons gagnantes
	var winning_combinations = [
		[1, 2, 3], [4, 5, 6], [7, 8, 9],  # Lignes
		[1, 4, 7], [2, 5, 8], [3, 6, 9],  # Colonnes
		[1, 5, 9], [3, 5, 7]              # Diagonales
	]
	
	for combo in winning_combinations:
		var a = grid_state[combo[0]]
		var b = grid_state[combo[1]]
		var c = grid_state[combo[2]]
		
		if a != null and a == b and b == c:
			win_grid(a)
			return
	
	# Vérifier le match nul
	var is_full = true
	for i in range(1, 10):
		if grid_state[i] == null:
			is_full = false
			break
	
	if is_full:
		draw_grid()

func win_grid(winner):
	GameState.set_big_grid_winner(grande_case_number, winner)

	is_won = true
	emit_signal("petite_grille_gagnee", grande_case_number, winner)

func draw_grid():
	GameState.set_big_grid_draw(grande_case_number)

	is_won = true
	emit_signal("petite_grille_nulle", grande_case_number)

func show_victory_symbol(winner):
	# Afficher un grand symbole au centre de la grande case (case 5)
	var center_case = shapes[4]  # Case 5 (index 4)
	var center_cshape = center_case.get_node("CShape5")
	
	# Effacer tous les petits symboles
	for i in range(9):
		var cshape = shapes[i].get_node("CShape" + str(i + 1))
		for child in cshape.get_children():
			child.queue_free()
	
	# Déterminer quel symbole instancier pour la victoire
	var symbol_type = get_symbol_type_for_player(winner)
	
	# Instancier le grand symbole de victoire
	var victory_symbol = symbol_scenes[symbol_type].instantiate()
	
	# Agrandir le symbole
	victory_symbol.scale = Vector2(symbol_won_scale, symbol_won_scale)
	victory_symbol.position = Vector2.ZERO
	
	# Ajouter le symbole de victoire au centre
	center_cshape.add_child(victory_symbol)

func set_playable(playable: bool, player: String):
	GameState.update_playable(grande_case_number, playable)

	is_playable = playable
	current_player = player
	
	# Cacher l'aperçu si la case devient non jouable
	if not playable:
		hide_preview()
	
	# Gérer l'animation du cadre
	if playable and not is_won:
		cadre_anim.visible = true
		cadre_anim.play("default")
		grille_anim.play("default")
	else:
		cadre_anim.stop()
		grille_anim.stop()
	
	# Optionnel : changer la couleur/opacité pour indiquer les cases jouables
	if not is_won:
		modulate = Color(1, 1, 1, 1) if playable else Color(0.5, 0.5, 0.5, 0.7)


func reset_grid():
	is_won = false
	is_playable = false
	modulate = Color(1, 1, 1, 1)
	hide_preview()
	current_hovered_case = null
	cadre_anim.stop()
	cadre_anim.visible = false
	
	for i in range(1, 10):
		grid_state[i] = null
	
	# Supprimer tous les symboles placés
	for i in range(9):
		var cshape = shapes[i].get_node("CShape" + str(i + 1))
		for child in cshape.get_children():
			child.queue_free()
