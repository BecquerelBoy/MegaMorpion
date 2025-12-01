extends Node

# Structure de stockage :
# big_grid_state = {
#   1: {
#        "cross": [1, 5, 9],
#        "circle": [2, 4],
#        "state": "cross" / "circle" / "draw" / "playable" / "locked"
#      },
#   2: { ... },
#   ...
# }

var big_grid_state := {}


func _ready():
	# Initialise les 9 grandes cases
	for i in range(1, 10):
		big_grid_state[i] = {
			"cross": [],
			"circle": [],
			"state": "locked"
		}


# --------------------------------------------------------------------
#   APPELÉ PAR CHAQUE GrandeCase quand une petite case est jouée
# --------------------------------------------------------------------
func register_symbol(big_number: int, small_number: int, symbol: String):
	# symbol = "cross" ou "circle"
	if big_number < 1 or big_number > 9:
		return
	
	if symbol == "cross":
		big_grid_state[big_number]["cross"].append(small_number)
	else:
		big_grid_state[big_number]["circle"].append(small_number)


# --------------------------------------------------------------------
#   APPELÉ PAR GrandeCase quand elle est gagnée
# --------------------------------------------------------------------
func set_big_grid_winner(big_number: int, winner: String):
	# winner = "cross" ou "circle"
	big_grid_state[big_number]["state"] = winner


# --------------------------------------------------------------------
#   APPELÉ PAR GrandeCase en cas de match nul
# --------------------------------------------------------------------
func set_big_grid_draw(big_number: int):
	big_grid_state[big_number]["state"] = "draw"


# --------------------------------------------------------------------
#   APPELÉ PAR Main pour définir les cases jouables
# --------------------------------------------------------------------
func update_playable(big_number: int, playable: bool):
	big_grid_state[big_number]["state"] = "playable" if playable else "locked"


# --------------------------------------------------------------------
#   Remise à zéro complète
# --------------------------------------------------------------------
func reset():
	for i in range(1, 10):
		big_grid_state[i]["cross"].clear()
		big_grid_state[i]["circle"].clear()
		big_grid_state[i]["state"] = "locked"


# --------------------------------------------------------------------
#   OUTILS DE CONSULTATION (optionnels)
# --------------------------------------------------------------------
func get_cross_positions(big_number: int) -> Array:
	return big_grid_state[big_number]["cross"]

func get_circle_positions(big_number: int) -> Array:
	return big_grid_state[big_number]["circle"]

func get_big_grid_state(big_number: int) -> String:
	return big_grid_state[big_number]["state"]
