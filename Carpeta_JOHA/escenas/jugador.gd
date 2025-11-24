extends CharacterBody2D

const SPEED = 150.0
@onready var animationPlayer = $AnimationPlayer # Asegúrate que el nodo se llama "AnimationPlayer"
@onready var sprite_node = $jugador # Renombré para evitar conflicto con la propiedad 'sprite' interna.
								   # Asegúrate que tu nodo visual se llama "jugador" y es un Sprite2D o AnimatedSprite2D.

func _physics_process(_delta):
	var direction = Vector2.ZERO
	var anim_to_play = "quieta" # Animación por defecto si no hay movimiento

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		anim_to_play = "correr"
		# Asegúrate de que sprite_node sea un Sprite2D o AnimatedSprite2D para tener 'flip_h'
		if sprite_node: 
			sprite_node.flip_h = false # Asume que "correr" se ve bien a la derecha por defecto
	elif Input.is_action_pressed("ui_left"): 
		direction.x -= 1 # Aquí debe ser -= 1 para ir a la izquierda
		anim_to_play = "correr" # Puedes usar la misma animación "correr" y voltearla
		if sprite_node:
			sprite_node.flip_h = true # Voltea el sprite para la izquierda
	elif Input.is_action_pressed("ui_down"):
		direction.y += 1
		anim_to_play = "deslizar" # O una animación de caminar hacia abajo si la tienes
		if sprite_node:
			sprite_node.flip_h = false # Puedes restablecer el flip si quieres que mire hacia adelante al bajar
	elif Input.is_action_pressed("ui_up"):
		direction.y -= 1
		anim_to_play = "saltar" # O una animación de caminar hacia arriba si la tienes
		if sprite_node:
			sprite_node.flip_h = false # Puedes restablecer el flip si quieres que mire hacia adelante al subir

	# Si hay movimiento, normalizamos la dirección y aplicamos la velocidad
	if direction.length() > 0:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
		anim_to_play = "quieta" # Asegura que la animación de "quieta" se reproduzca si no hay entrada

	# Reproducir la animación solo si es diferente a la actual
	if animationPlayer and animationPlayer.current_animation != anim_to_play:
		animationPlayer.play(anim_to_play)
		
	move_and_slide()
