extends Node2D

# Références aux grandes cases
var grandes_cases = []

# Variables de jeu
var current_player = "cross"  # "cross" ou "circle"
var grande_case_states = {}  # Stocke l'état de chaque grande case (null, "cross", "circle", "draw")
var next_grande_case = null  # null = jouer n'importe où, sinon numéro de la case
var game_over = false

# Référence au label de victoire
@onready var win_label = $WinLabel
@onready var you: AnimatedSprite2D = $Characters/You
@onready var dragon: AnimatedSprite2D = $Characters/dragon
@onready var button_play_anim: AnimatedSprite2D = $PauseButton/ButtonPlayAnim

var pause_instance = null
const PAUSE_MENU = preload("uid://dlckbqy80trbh")
@onready var pause_menu = preload("res://Scene/pause_menu.tscn")


func _ready():
	# Cacher le label de victoire au début
	win_label.visible = false
	
	# Démarrer les animations par défaut
	you.play("default")
	dragon.play("default")
	
	# Connecter les signaux de fin d'animation
	you.animation_finished.connect(_on_you_animation_finished)
	dragon.animation_finished.connect(_on_dragon_animation_finished)
	
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

func _process(_delta):
	GridEvaluator.update_all_scores(self)

func _on_you_animation_finished():
	# Revenir à l'animation par défaut après l'attaque
	if you.animation == "atk":
		you.play("default")

func _on_dragon_animation_finished():
	# Revenir à l'animation par défaut après l'attaque
	if dragon.animation == "atk":
		dragon.play("default")

func _on_case_jouee(grande_case_num, petite_case_num):
	# Jouer l'animation d'attaque du joueur
	you.play("atk")
	
	if game_over:
		return
	
	# Déterminer la prochaine grande case où jouer
	next_grande_case = petite_case_num
	
	# Si la case de destination est déjà gagnée ou nulle, on peut jouer n'importe où
	if grande_case_states[next_grande_case] != null:
		next_grande_case = null
	
	# Vérifier s'il y a un gagnant au Super Morpion
	check_super_morpion()
	
	if game_over:
		return
	
	# Alterner le joueur UNE SEULE FOIS
	current_player = "circle" if current_player == "cross" else "cross"
	
	# Mettre à jour les cases jouables
	update_playable_cases()
	
	# Si c'est au tour de l'IA, elle joue
	if current_player == "circle":
		ia_play()

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

func reset_game():
	game_over = false
	current_player = "cross"
	next_grande_case = null
	
	# Cacher le label de victoire
	win_label.visible = false
	
	# Réinitialiser les animations
	you.play("default")
	dragon.play("default")
	
	for i in range(1, 10):
		grande_case_states[i] = null
		grandes_cases[i - 1].reset_grid()
	
	update_playable_cases()

# --- IA : joue pour les ronds avec analyse des coups adverses ---
func ia_play():
	if current_player != "circle" or game_over:
		return

	var best_grande = null
	var best_petite = null
	var best_score = -INF

	# Parcourt toutes les grandes cases
	for i in range(1, 10):
		var grande_case = grandes_cases[i - 1]
		# Ne considérer que les grandes cases jouables
		if not grande_case.is_playable:
			continue

		# Parcourt toutes les petites cases libres dans cette grande case
		for j in range(1, 10):
			if grande_case.grid_state[j] != null:
				continue

			# Évaluer ce coup en profondeur
			var move_score = evaluate_move_with_depth(i, j)

			if move_score > best_score:
				best_score = move_score
				best_grande = i
				best_petite = j

	# Jouer le meilleur coup trouvé (si un existe)
	if best_grande != null and best_petite != null:
		var chosen_case = grandes_cases[best_grande - 1]
		await get_tree().create_timer(0.5).timeout
		
		# Jouer l'animation d'attaque du dragon
		dragon.play("atk")
		
		await get_tree().create_timer(0.5).timeout
		
		# Placer le symbole SANS passer par le signal
		chosen_case.place_symbol_forced(best_petite, "circle")
		
		# Gérer manuellement la suite du jeu
		next_grande_case = best_petite
		
		# Si la case de destination est déjà gagnée ou nulle, on peut jouer n'importe où
		if grande_case_states[next_grande_case] != null:
			next_grande_case = null
		
		# Vérifier s'il y a un gagnant au Super Morpion
		check_super_morpion()
		
		if game_over:
			return
		
		# Repasser au joueur humain
		current_player = "cross"
		
		# Mettre à jour les cases jouables
		update_playable_cases()


# Évalue un coup de l'IA en simulant les réponses possibles du joueur
func evaluate_move_with_depth(ia_big: int, ia_small: int) -> float:
	# Déterminer où le joueur devra jouer après ce coup
	var player_next_big = ia_small
	if grande_case_states.get(player_next_big, null) != null:
		player_next_big = null  # Joueur peut jouer partout
	
	# Simuler le coup de l'IA
	var sim_list = GameState.big_grid_state[ia_big]["circle"]
	sim_list.append(ia_small)
	
	# Score initial : évaluation directe de la position
	var base_score = 0.0
	
	# 1. Évaluer si ce coup gagne la grande case
	if check_simulated_win(ia_big, "circle"):
		base_score += 10.0  # Gagner une grande case est excellent
	
	# 2. Évaluer si ce coup bloque une victoire adverse
	var sim_cross = GameState.big_grid_state[ia_big]["cross"]
	if check_would_win(ia_big, ia_small, "cross"):
		base_score += 5.0  # Bloquer une victoire est important
	
	# 3. Analyser les coups possibles du joueur
	var player_responses_score = analyze_player_responses(player_next_big)
	
	# Le score final combine la valeur du coup ET les opportunités laissées à l'adversaire
	var final_score = base_score - player_responses_score
	
	# Annuler la simulation
	sim_list.erase(ia_small)
	
	return final_score


# Analyse tous les coups possibles du joueur après un coup de l'IA
func analyze_player_responses(player_next_big) -> float:
	var worst_case_for_ia = -INF  # Le meilleur score que le joueur peut obtenir
	
	if player_next_big == null:
		# Le joueur peut jouer partout : analyser toutes les grandes cases
		for big_idx in range(1, 10):
			if grande_case_states.get(big_idx, null) != null:
				continue  # Case déjà gagnée
			
			var best_in_case = analyze_player_moves_in_case(big_idx)
			if best_in_case > worst_case_for_ia:
				worst_case_for_ia = best_in_case
	else:
		# Le joueur est forcé dans une case spécifique
		if grande_case_states.get(player_next_big, null) == null:
			worst_case_for_ia = analyze_player_moves_in_case(player_next_big)
		else:
			# La case est déjà gagnée, le joueur peut jouer partout
			for big_idx in range(1, 10):
				if grande_case_states.get(big_idx, null) != null:
					continue
				
				var best_in_case = analyze_player_moves_in_case(big_idx)
				if best_in_case > worst_case_for_ia:
					worst_case_for_ia = best_in_case
	
	return worst_case_for_ia if worst_case_for_ia != -INF else 0.0


# Analyse tous les coups possibles du joueur dans une grande case donnée
func analyze_player_moves_in_case(big_idx: int) -> float:
	var grande_case = grandes_cases[big_idx - 1]
	var best_player_score = -INF
	
	for small_idx in range(1, 10):
		if grande_case.grid_state[small_idx] != null:
			continue
		
		# Simuler le coup du joueur
		var sim_cross = GameState.big_grid_state[big_idx]["cross"]
		sim_cross.append(small_idx)
		
		var move_value = 0.0
		
		# Le joueur gagne-t-il cette grande case ?
		if check_simulated_win(big_idx, "cross"):
			move_value += 8.0  # Très mauvais pour l'IA
		
		# Le joueur bloque-t-il une victoire de l'IA ?
		if check_would_win(big_idx, small_idx, "circle"):
			move_value += 3.0
		
		# Évaluer la case où l'IA devra jouer ensuite
		var ia_next_big = small_idx
		if grande_case_states.get(ia_next_big, null) != null:
			ia_next_big = null
		
		# Ajouter le score de la position résultante
		if ia_next_big == null:
			# L'IA peut jouer partout : trouver la meilleure case pour l'IA
			var best_ia_case_score = -INF
			for next_big in range(1, 10):
				if grande_case_states.get(next_big, null) == null:
					var case_score = GridEvaluator.evaluate_big_case(next_big)
					if case_score > best_ia_case_score:
						best_ia_case_score = case_score
			move_value -= best_ia_case_score  # Moins c'est bon pour l'IA, plus c'est mauvais
		else:
			# L'IA est forcée dans une case : évaluer cette case
			var forced_score = GridEvaluator.evaluate_big_case(ia_next_big)
			move_value -= forced_score
		
		# Annuler la simulation
		sim_cross.erase(small_idx)
		
		if move_value > best_player_score:
			best_player_score = move_value
	
	return best_player_score if best_player_score != -INF else 0.0


# Vérifie si un coup gagnerait une grande case (sans le placer réellement)
func check_would_win(big_idx: int, small_idx: int, player: String) -> bool:
	var positions = GameState.big_grid_state[big_idx][player].duplicate()
	positions.append(small_idx)
	
	for combo in [[1,2,3], [4,5,6], [7,8,9], [1,4,7], [2,5,8], [3,6,9], [1,5,9], [3,5,7]]:
		if combo[0] in positions and combo[1] in positions and combo[2] in positions:
			return true
	
	return false


# Vérifie si une grande case est gagnée dans la simulation actuelle
func check_simulated_win(big_idx: int, player: String) -> bool:
	var positions = GameState.big_grid_state[big_idx][player]
	
	for combo in [[1,2,3], [4,5,6], [7,8,9], [1,4,7], [2,5,8], [3,6,9], [1,5,9], [3,5,7]]:
		if combo[0] in positions and combo[1] in positions and combo[2] in positions:
			return true
	
	return false


func _input(event):
	if event.is_action_pressed("ui_accept"):  # Touche Entrée
		reset_game()


func _on_pause_button_mouse_entered() -> void:
	button_play_anim.play("Play")

func _on_pause_button_pressed() -> void:
	if pause_instance == null:
		print("Jeu en pause")
		get_tree().paused = true
		pause_instance = pause_menu.instantiate()
		pause_instance.z_index = 100
		add_child(pause_instance)
