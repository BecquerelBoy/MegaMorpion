extends Node

@onready var player_display1 = $AnimDisplay/PlayerDisplay1
@onready var player_display2 = $AnimDisplay/PlayerDisplay2
@onready var player_select1 = $CharacterSelection/PlayerSelect1
@onready var player_select2 = $CharacterSelection/PlayerSelect2

func _ready():
	# Connecter les signaux des OptionButton
	player_select1.item_selected.connect(_on_player_select1_item_selected)
	player_select2.item_selected.connect(_on_player_select2_item_selected)
	
	# Initialiser les animations avec la première sélection
	_update_animation(player_select1, player_display1, true)
	_update_animation(player_select2, player_display2, false)

func _on_player_select1_item_selected(_index):
	_update_animation(player_select1, player_display1, true)

func _on_player_select2_item_selected(_index):
	_update_animation(player_select2, player_display2, false)

func _update_animation(option_button: OptionButton, animated_sprite: AnimatedSprite2D, is_player1: bool):
	# Récupérer le texte de l'élément sélectionné
	var selected_text = option_button.get_item_text(option_button.selected)
	
	# Sauvegarder dans le script global
	if is_player1:
		Global.player1_character = selected_text
	else:
		Global.player2_character = selected_text
	
	# Vérifier si l'animation existe
	if animated_sprite.sprite_frames.has_animation(selected_text):
		animated_sprite.play(selected_text)
	else:
		push_warning("Animation '" + selected_text + "' n'existe pas dans l'AnimatedSprite2D")


func _on_ready_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/GameMode2.tscn")
