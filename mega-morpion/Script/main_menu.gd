extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var play: CustomButton = $CanvasLayer/Play
@onready var quit: CustomButton = $CanvasLayer/Quit
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var button_play_anim: AnimatedSprite2D = $CanvasLayer/Play/ButtonPlayAnim
@onready var button_quit_anim: AnimatedSprite2D = $CanvasLayer/Quit/ButtonQuitAnim
@onready var button_1v1_anim: AnimatedSprite2D = $"CanvasLayer/1v1/AnimatedSprite2D"
@onready var main_theme: AudioStreamPlayer2D = $MainTheme

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	MusicManager.restore_volume(0.8)
	animation_player.play("fade_in")
	
	# Connecter les signaux des boutons
	play.pressed.connect(_on_play_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	# Connecter les signaux pour les animations des AnimatedSprite2D (souris)
	play.mouse_entered.connect(_on_play_mouse_entered)
	quit.mouse_entered.connect(_on_quit_mouse_entered)
	
	if main_theme.stream:
		MusicManager.play_music(main_theme.stream, 1.0)

func _on_play_mouse_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_play_anim.play("Play")

func _on_v_1_mouse_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_1v1_anim.play("default")


func _on_quit_mouse_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_quit_anim.play("Quit")

func _on_play_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	MusicManager.stop_music(0.4)
	get_tree().change_scene_to_file("res://Scene/Level_1.tscn")

func _on_v_1_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	MusicManager.stop_music(0.4)
	get_tree().change_scene_to_file("res://Scene/CharacterSelection.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func delete():
	color_rect.queue_free()
