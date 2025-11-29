extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var resume: CustomButton = $CanvasLayer/Resume
@onready var main_menu: CustomButton = $CanvasLayer/MainMenu
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var button_play_anim: AnimatedSprite2D = $CanvasLayer/Resume/ButtonPlayAnim
@onready var button_main_menu_anim: AnimatedSprite2D = $CanvasLayer/MainMenu/ButtonMainMenuAnim
@onready var main_theme: AudioStreamPlayer2D = $MainTheme

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	MusicManager.restore_volume(0.8)
	animation_player.play("fade_in")
	
	if main_theme.stream:
		MusicManager.play_music(main_theme.stream, 1.0)

func _on_resume_mouse_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_play_anim.play("Play")

func _on_resume_pressed() -> void:
	get_tree().paused = false
	queue_free()
	
func _on_main_menu_mouse_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_main_menu_anim.play("default")

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	MusicManager.stop_music(0.4)
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")

func delete():
	color_rect.queue_free()
