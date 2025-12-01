extends TextureButton
class_name CustomButton

# Courbes éditables dans l'inspecteur
@export var hover_scale_curve: Curve
@export var press_scale_curve: Curve

# Paramètres d'animation
@export var hover_duration: float = 0.1
@export var press_duration: float = 0.2
@export var hover_max_scale: float = 1.2
@export var press_max_scale: float = 1.4

# Variables internes
var original_scale: Vector2
var current_tween: Tween
var is_button_hovered: bool = false

func _ready():
	# Sauvegarder la taille originale
	original_scale = scale
	
	# Désactiver complètement le focus
	focus_mode = Control.FOCUS_NONE
	
	# Connecter uniquement les signaux de souris
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered():
	is_button_hovered = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	animate_with_curve(hover_scale_curve, hover_max_scale, hover_duration)

func _on_mouse_exited():
	is_button_hovered = false
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	animate_to_original_size()

func _on_button_down():
	if is_button_hovered:
		animate_with_curve(press_scale_curve, press_max_scale, press_duration)

func _on_button_up():
	if is_button_hovered:
		# Retourner à la taille de hover après le press
		animate_with_curve(hover_scale_curve, hover_max_scale, hover_duration)

func animate_with_curve(curve: Curve, max_scale: float, duration: float):
	# Arrêter l'animation précédente
	if current_tween:
		current_tween.kill()
	
	# Si pas de courbe, utiliser une animation simple
	if curve == null:
		current_tween = create_tween()
		var target_scale = original_scale * max_scale
		current_tween.tween_property(self, "scale", target_scale, duration)
		return
	
	# Animation avec courbe personnalisée
	current_tween = create_tween()
	
	# Créer une fonction qui sera appelée à chaque frame
	current_tween.tween_method(
		func(progress: float):
			var curve_value = curve.sample(progress)
			var scale_multiplier = 1.0 + (max_scale - 1.0) * curve_value
			scale = original_scale * scale_multiplier,
		0.0,
		1.0,
		duration
	)

func animate_to_original_size():
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.tween_property(self, "scale", original_scale, 0.2)
