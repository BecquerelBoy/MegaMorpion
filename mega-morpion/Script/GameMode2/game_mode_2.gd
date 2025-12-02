extends Node2D

# Références aux grandes cases
var grandes_cases = []

# Variables de jeu
var current_player = "cross"  # "cross" ou "circle"
var grande_case_states = {}  # Stocke l'état de chaque grande case (null, "cross", "circle", "draw")
var next_grande_case = null  # null = jouer n'importe où, sinon numéro de la case
var game_over = false

var pause_instance = null
@onready var pause_menu = preload("res://Scene/pause_menu_1V1.tscn")

# Référence au label de victoire
@onready var win_label = $WinLabel
@onready var player_1: AnimatedSprite2D = $Players/AnimPlayer1
@onready var player_2: AnimatedSprite2D = $Players/AnimPlayer2
@onready var button_play_anim: AnimatedSprite2D = $PauseButton/ButtonPlayAnim

func _ready():
	# Cacher le label de victoire au début
	win_label.visible = false
	
	# Charger les animations des personnages sélectionnés
	if player_1.sprite_frames.has_animation(Global.player1_character):
		player_1.play(Global.player1_character)
	else:
		player_1.play("default")
		push_warning("Animation '" + Global.player1_character + "' introuvable pour Player1")
	
	if player_2.sprite_frames.has_animation(Global.player2_character):
		player_2.play(Global.player2_character)
	else:
		player_2.play("default")
		push_warning("Animation '" + Global.player2_character + "' introuvable pour Player2")
	
	# Récupérer toutes les grandes cases
	for i in range(1, 10):
		var grande_case = get_node("GrandeGrille/GrandeCase" + str(i))
		grandes_cases.append(grande_case)
		grande_case_states[i] = null
		
		# Connecter le signal de victoire de chaque petite grille
		grande_case.connect("petite_grille_gagnee", _on_petite_grille_gagnee)
		grande_case.connect("petite_grille_nulle", _on_petite_grille_nulle)
		grande_case.connect("case_jouee", _on_case_jouee)
	
	# Initialiser : le premier joueur peut jouer n'importe où
	update_playable_cases()

func _on_case_jouee(_grande_case_num, petite_case_num):
	if game_over:
		return
	
	# Déterminer la prochaine grande case où jouer
	next_grande_case = petite_case_num
	
	# Alterner le joueur
	current_player = "circle" if current_player == "cross" else "cross"
	
	# Attendre la fin du frame pour que les signaux de victoire soient traités
	await get_tree().process_frame
	
	# Si la case de destination est déjà gagnée ou nulle, on peut jouer n'importe où
	if grande_case_states[next_grande_case] != null:
		next_grande_case = null
	
	# Mettre à jour les cases jouables
	update_playable_cases()
	
	# Vérifier s'il y a un gagnant au Super Morpion
	check_super_morpion()
	
	
func _on_petite_grille_gagnee(grande_case_num, winner):
	grande_case_states[grande_case_num] = winner
	print("Grande case ", grande_case_num, " gagnée par ", winner)
	
	# Afficher un grand symbole sur la grande case gagnée
	var grande_case = grandes_cases[grande_case_num - 1]
	grande_case.show_victory_symbol(winner)

func _on_petite_grille_nulle(grande_case_num):
	grande_case_states[grande_case_num] = "draw"
	print("Grande case ", grande_case_num, " : égalité")

func update_playable_cases():
	for i in range(1, 10):
		var grande_case = grandes_cases[i - 1]
		
		if next_grande_case == null:
			# Peut jouer partout sauf dans les cases gagnées/nulles
			grande_case.set_playable(grande_case_states[i] == null and not game_over, current_player)
		else:
			# Ne peut jouer que dans la case désignée
			grande_case.set_playable(i == next_grande_case and not game_over, current_player)

func check_super_morpion():
	# Combinaisons gagnantes pour le Super Morpion
	var winning_combinations = [
		[1, 2, 3], [4, 5, 6], [7, 8, 9],  # Lignes
		[1, 4, 7], [2, 5, 8], [3, 6, 9],  # Colonnes
		[1, 5, 9], [3, 5, 7]              # Diagonales
	]
	
	for combo in winning_combinations:
		var a = grande_case_states[combo[0]]
		var b = grande_case_states[combo[1]]
		var c = grande_case_states[combo[2]]
		
		if a != null and a != "draw" and a == b and b == c:
			announce_super_winner(a)
			return
	
	# Vérifier si toutes les grandes cases sont terminées
	var all_finished = true
	for i in range(1, 10):
		if grande_case_states[i] == null:
			all_finished = false
			break
	
	if all_finished:
		count_winner()

func announce_super_winner(winner):
	game_over = true
	update_playable_cases()
	
	# Afficher le label de victoire avec le nom du gagnant
	win_label.visible = true
	if winner == "cross":
		win_label.text = "VICTOIRE DE LA CROIX !"
	else:
		win_label.text = "VICTOIRE DU ROND !"
	
	print("SUPER MORPION ! Le joueur ", winner, " a gagné la partie !")

func count_winner():
	game_over = true
	var cross_count = 0
	var circle_count = 0
	
	for i in range(1, 10):
		if grande_case_states[i] == "cross":
			cross_count += 1
		elif grande_case_states[i] == "circle":
			circle_count += 1
	
	# Afficher le label de victoire avec le résultat
	win_label.visible = true
	if cross_count > circle_count:
		win_label.text = "VICTOIRE DE LA CROIX !\n" + str(cross_count) + " plaquettes contre " + str(circle_count)
		print("Victoire de la croix avec ", cross_count, " plaquettes contre ", circle_count)
	elif circle_count > cross_count:
		win_label.text = "VICTOIRE DU ROND !\n" + str(circle_count) + " plaquettes contre " + str(cross_count)
		print("Victoire du rond avec ", circle_count, " plaquettes contre ", cross_count)
	else:
		win_label.text = "MATCH NUL !\n" + str(cross_count) + " plaquettes chacun"
		print("Match nul ! ", cross_count, " plaquettes chacun")
	
	update_playable_cases()


func _on_pause_button_mouse_entered() -> void:
	button_play_anim.play("Play")

func _on_pause_button_pressed() -> void:
	if pause_instance == null:
		print("Jeu en pause")
		get_tree().paused = true
		pause_instance = pause_menu.instantiate()
		pause_instance.z_index = 100
		add_child(pause_instance)
