extends Node

@onready var player_display1 = $AnimDisplay/PlayerDisplay1
@onready var player_display2 = $AnimDisplay/PlayerDisplay2
@onready var player_select1 = $CharacterSelection/PlayerSelect1
@onready var player_select2 = $CharacterSelection/PlayerSelect2

@onready var ready_anim_button: AnimatedSprite2D = $Ready/ReadyAnimButton
@onready var return_anim_button: AnimatedSprite2D = $Return/ReturnAnimButton

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
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	MusicManager.stop_music(0.4)
	get_tree().change_scene_to_file("res://Scene/GameMode2.tscn")

func _on_ready_mouse_entered() -> void:
	ready_anim_button.play("ready")

func _on_return_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	MusicManager.stop_music(0.4)
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")

func _on_return_mouse_entered() -> void:
	return_anim_button.play("return")
