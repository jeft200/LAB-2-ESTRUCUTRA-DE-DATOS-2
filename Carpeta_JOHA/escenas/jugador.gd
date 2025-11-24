extends CharacterBody2D

const SPEED = 150.0
@onready var animationPlayer = $jugadorAnimacion
@onready var sprite = $Sprite2D # AsegÃºrate de que tu nodo Sprite2D se llame asÃ­ o ajusta el nombre.

func _physics_process(_delta):
	var direction = Vector2.ZERO
	var anim_to_play = "parada" # AnimaciÃ³n por defecto si no hay movimiento

	if Input.is_action_pressed("ui_right"):
		direction.x += 1 
		anim_to_play = "caminar"
		sprite.flip_h = false # Asume que "derecha" es la orientaciÃ³n normal del sprite
	elif Input.is_action_pressed("ui_left"): # Usamos 'elif' para priorizar el movimiento si se presionan ambos
		direction.x -= 1
		anim_to_play = "caminar"
		sprite.flip_h = true # Voltea el sprite para la izquierda
	elif Input.is_action_pressed("ui_down"):
		direction.y += 1
		anim_to_play = "parada" # O "abajo", si tienes una animaciÃ³n especÃ­fica para ir hacia abajo
	elif Input.is_action_pressed("ui_up"):
		direction.y -= 1
		anim_to_play = "saltar" # O "arriba", si tienes una animaciÃ³n especÃ­fica para ir hacia arriba

	# Si hay movimiento, normalizamos la direcciÃ³n y aplicamos la velocidad
	if direction.length() > 0:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
		anim_to_play = "parada" # Asegura que la animaciÃ³n de "parada" se reproduzca si no hay entrada


		
	move_and_slide()
