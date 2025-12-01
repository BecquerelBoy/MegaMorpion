extends Node

# Combinaisons gagnantes d'une grille 3x3
const LINES = [
	[1,2,3], [4,5,6], [7,8,9],      # Lignes
	[1,4,7], [2,5,8], [3,6,9],      # Colonnes
	[1,5,9], [3,5,7]                # Diagonales
]

# Renvoie un score entre -1 et 1
func evaluate_big_case(big_number: int) -> float:
	var data = GameState.big_grid_state[big_number]

	var cross_positions = data["cross"]
	var circle_positions = data["circle"]
	var state = data["state"]

	# Cas gagnés ou nuls
	if state == "cross":
		return -1.0
	if state == "circle":
		return 1.0
	if state == "draw":
		return 0.0

	# Heuristique :
	var score := 0.0

	for line in LINES:
		var c_cross := 0
		var c_circle := 0

		for cell in line:
			if cell in cross_positions:
				c_cross += 1
			elif cell in circle_positions:
				c_circle += 1

		# Si les deux types sont présents → ligne bloquée
		if c_cross > 0 and c_circle > 0:
			continue

		# Ligne entièrement libre → neutre, mais légèrement positive si jouable
		if c_cross == 0 and c_circle == 0:
			score += 0.05
			continue

		# Une ligne proches de gagner vaut plus
		if c_cross == 1:  score -= 0.2
		if c_cross == 2:  score -= 0.5

		if c_circle == 1: score += 0.2
		if c_circle == 2: score += 0.5

	# Normalisation finale pour rester entre -1 et 1
	return clamp(score, -1.0, 1.0)


# Met à jour tous les labels d’un coup
func update_all_scores(main_node: Node):
	var score_label = main_node.get_node("ScoreLabel")
	var score_bar = main_node.get_node("ScoreBar")

	for i in range(1, 10):
		var score = evaluate_big_case(i)

		# --- Mise à jour des labels ---
		var label = score_label.get_node("GrandeCase" + str(i) + "Score")
		label.text = str(round(score * 100) / 100.0)

		# --- Mise à jour des ProgressBar ---
		var bar = score_bar.get_node("GrandeCase" + str(i) + "Bar")
		bar.value = (score + 1.0) * 50.0
