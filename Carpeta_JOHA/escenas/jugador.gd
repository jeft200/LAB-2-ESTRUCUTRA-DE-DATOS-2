extends CharacterBody2D

const SPEED = 150.0
@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D # Asegúrate de que tu nodo Sprite2D se llame así o ajusta el nombre.

func _physics_process(_delta):
	# Verificar si el juego sigue activo
	var laberinto = get_parent()
	if laberinto and "mision_activa" in laberinto and not laberinto.mision_activa:
		velocity = Vector2.ZERO
		return  # Detener el procesamiento
	var direction = Vector2.ZERO
	var anim_to_play = "parada" # Animación por defecto si no hay movimiento
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1 
		anim_to_play = "derecha"
		sprite.flip_h = false # Asume que "derecha" es la orientación normal del sprite
	elif Input.is_action_pressed("ui_left"): # Usamos 'elif' para priorizar el movimiento si se presionan ambos
		direction.x -= 1
		anim_to_play = "izquierda"
		sprite.flip_h = true # Voltea el sprite para la izquierda
	elif Input.is_action_pressed("ui_down"):
		direction.y += 1
		anim_to_play = "parada" # O "abajo", si tienes una animación específica para ir hacia abajo
	elif Input.is_action_pressed("ui_up"):
		direction.y -= 1
		anim_to_play = "atras" # O "arriba", si tienes una animación específica para ir hacia arriba

	# Si hay movimiento, normalizamos la dirección y aplicamos la velocidad
	if direction.length() > 0:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
		anim_to_play = "parada" # Asegura que la animación de "parada" se reproduzca si no hay entrada

	# Reproducir la animación si es diferente a la actual
	if animationPlayer.current_animation != anim_to_play:
		animationPlayer.play(anim_to_play)
		
	move_and_slide()
