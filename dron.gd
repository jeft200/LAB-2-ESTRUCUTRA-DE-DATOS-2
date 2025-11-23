extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export_group("Movimiento")
@export var velocidad_movimiento: float = 250.0
@export var velocidad_patrulla: float = 100.0
@export var aceleracion: float = 800.0
@export var distancia_pegado: float = 150.0 # Distancia para dejar de acercarse y disparar

# --- LÍMITES Y COMBATE ---
@export_group("Combate")
@export var min_x: float = 0.0
@export var max_x: float = 1500.0
@export var min_y: float = 0.0
@export var max_y: float = 1000.0
@export var radio_detectar: float = 300.0
@export var projectil_scene: PackedScene
@export var tiempo_entre_disparos: float = 0.8

# --- VISUAL ---
@export_group("Visual")
@export var debug_visual: bool = true
@export var color_alerta: Color = Color(1, 0, 0, 0.6)
@export var color_normal: Color = Color(0.2, 0, 0, 0.4)

# --- NODOS ---
# Asegúrate de que los nombres coincidan con tu escena
@onready var vision_area: Area2D = $VisionArea
@onready var firing_point: Node2D = $FiringPoint
@onready var fire_timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- VARIABLES INTERNAS ---
var objetivo: CharacterBody2D = null
var puede_disparar: bool = true
var last_seen_position: Vector2
var buscando: bool = false
var patrullando: bool = true
var punto_objetivo: Vector2
var label_debug: Label

func _ready() -> void:
	# Configuración inicial
	punto_objetivo = global_position
	fire_timer.wait_time = tiempo_entre_disparos
	
	# Conectar señales si no están conectadas desde el editor
	if not fire_timer.timeout.is_connected(_on_timer_timeout):
		fire_timer.timeout.connect(_on_timer_timeout)
	
	if not vision_area.body_entered.is_connected(_on_vision_area_body_entered):
		vision_area.body_entered.connect(_on_vision_area_body_entered)
	if not vision_area.body_exited.is_connected(_on_vision_area_body_exited):
		vision_area.body_exited.connect(_on_vision_area_body_exited)

	# Configurar forma de colisión de visión dinámicamente
	var collision_node = vision_area.get_node_or_null("CollisionShape2D")
	if collision_node and collision_node.shape is CircleShape2D:
		collision_node.shape.radius = radio_detectar

	# Crear etiqueta de debug
	if debug_visual:
		label_debug = Label.new()
		label_debug.position = Vector2(-50, -60)
		add_child(label_debug)

	if animated_sprite: 
		animated_sprite.play("flying") # Asegúrate de que la animación exista
	
	_set_alert_color(color_normal)
	_obtener_nuevo_punto_patrulla()

func _physics_process(delta: float) -> void:
	var vel_deseada = Vector2.ZERO
	var velocidad_actual_max = velocidad_patrulla
	var estado_txt = "Patrullando"
	
	# --- LÓGICA DE ESTADOS ---
	
	if objetivo:
		# ESTADO: PERSECUCIÓN
		estado_txt = "PERSIGUIENDO"
		last_seen_position = objetivo.global_position
		buscando = false
		patrullando = false
		velocidad_actual_max = velocidad_movimiento
		
		var diferencia = objetivo.global_position - global_position
		var distancia = diferencia.length()
		
		# Rotar hacia el objetivo (opcional, visual)
		if animated_sprite:
			animated_sprite.flip_h = diferencia.x < 0
		
		if distancia > distancia_pegado:
			# Acercarse
			vel_deseada = diferencia.normalized() * velocidad_actual_max
		else:
			# Está en rango, quedarse quieto y disparar
			vel_deseada = Vector2.ZERO
			estado_txt = "DISPARANDO"
			_intentar_disparar()

	elif buscando:
		# ESTADO: BÚSQUEDA (Ir a la última posición conocida)
		estado_txt = "BUSCANDO"
		var diferencia = last_seen_position - global_position
		
		if diferencia.length() > 10.0:
			vel_deseada = diferencia.normalized() * velocidad_movimiento
		else:
			# Llegó al último punto y no vio nada, volver a patrullar
			buscando = false
			patrullando = true
			_obtener_nuevo_punto_patrulla()

	elif patrullando:
		# ESTADO: PATRULLA
		var diferencia = punto_objetivo - global_position
		if diferencia.length() > 10.0:
			vel_deseada = diferencia.normalized() * velocidad_patrulla
		else:
			_obtener_nuevo_punto_patrulla()

	# --- MOVIMIENTO SUAVIZADO ---
	velocity = velocity.move_toward(vel_deseada, aceleracion * delta)
	move_and_slide()
	
	# --- DEBUG VISUAL ---
	if debug_visual and label_debug:
		label_debug.text = estado_txt + "\nVel: " + str(velocity.length())

func _intentar_disparar() -> void:
	if puede_disparar and projectil_scene:
		puede_disparar = false
		fire_timer.start()
		
		# Instanciar proyectil
		var bullet = projectil_scene.instantiate()
		bullet.global_position = firing_point.global_position
		
		# Calcular dirección hacia el objetivo
		if objetivo:
			var direction = (objetivo.global_position - global_position).normalized()
			# Asumiendo que el proyectil tiene una variable 'direction' o usa rotación
			if "direction" in bullet:
				bullet.direction = direction
			else:
				bullet.rotation = direction.angle()
		
		get_tree().current_scene.add_child(bullet)

func _obtener_nuevo_punto_patrulla() -> void:
	var x_rand = randf_range(min_x, max_x)
	var y_rand = randf_range(min_y, max_y)
	punto_objetivo = Vector2(x_rand, y_rand)

func _set_alert_color(color: Color) -> void:
	if animated_sprite:
		animated_sprite.modulate = color

# --- SEÑALES ---

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		objetivo = body
		_set_alert_color(color_alerta)

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == objetivo:
		objetivo = null
		buscando = true
		_set_alert_color(color_normal)

func _on_timer_timeout() -> void:
	puede_disparar = true
