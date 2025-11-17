extends Node2D

# Références aux grandes cases
var grandes_cases = []

# Variables de jeu
var current_player = "cross"  # "cross" ou "circle"
var grande_case_states = {}  # Stocke l'état de chaque grande case (null, "cross", "circle", "draw")
var next_grande_case = null  # null = jouer n'importe où, sinon numéro de la case
var game_over = false

func _ready():
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

func _on_case_jouee(grande_case_num, petite_case_num):
	if game_over:
		return
	
	# Déterminer la prochaine grande case où jouer
	next_grande_case = petite_case_num
	
	# Si la case de destination est déjà gagnée ou nulle, on peut jouer n'importe où
	if grande_case_states[next_grande_case] != null:
		next_grande_case = null
	
	# Alterner le joueur
	current_player = "circle" if current_player == "cross" else "cross"
	
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
	print("SUPER MORPION ! Le joueur ", winner, " a gagné la partie !")
	update_playable_cases()

func count_winner():
	game_over = true
	var cross_count = 0
	var circle_count = 0
	
	for i in range(1, 10):
		if grande_case_states[i] == "cross":
			cross_count += 1
		elif grande_case_states[i] == "circle":
			circle_count += 1
	
	if cross_count > circle_count:
		print("Victoire de la croix avec ", cross_count, " plaquettes contre ", circle_count)
	elif circle_count > cross_count:
		print("Victoire du rond avec ", circle_count, " plaquettes contre ", cross_count)
	else:
		print("Match nul ! ", cross_count, " plaquettes chacun")
	
	update_playable_cases()

func reset_game():
	game_over = false
	current_player = "cross"
	next_grande_case = null
	
	for i in range(1, 10):
		grande_case_states[i] = null
		grandes_cases[i - 1].reset_grid()
	
	update_playable_cases()

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Touche Entrée
		reset_game()
