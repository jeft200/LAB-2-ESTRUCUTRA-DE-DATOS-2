extends CharacterBody2D

# --- PROPIEDADES EXPORTADAS ---
@export var radio_detectar: float = 150.0
@export var velocidad_movimiento: float = 50.0
@export var velocidad_busqueda: float = 30.0
@export var velocidad_patrulla: float = 40.0
@export var ratio_fuego: float = 0.5
@export var projectil_scene: PackedScene
@export var color_alerta: Color = Color(1, 0, 0)
@export var color_normal: Color = Color(0.2, 0, 0)
@export var area_limite_path: NodePath
@export var margen_limite: float = 20.0

# --- NODOS HIJOS ---
@onready var vision_area: Area2D = $VisionArea
@onready var alert_shape: Node2D = $VisionArea
@onready var firing_point: Node2D = $FiringPoint
@onready var fire_timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# --- VARIABLES INTERNAS ---
var objetivo: CharacterBody2D = null
var puede_disparar: bool = true
var last_seen_position: Vector2 = Vector2.ZERO
var buscando: bool = false
var punto_objetivo: Vector2 = Vector2.ZERO
var patrullando: bool = true

func _ready() -> void:
	# Configurar Timer
	fire_timer.wait_time = ratio_fuego
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	
	# Configurar área de visión
	var shape = CircleShape2D.new()
	shape.radius = radio_detectar
	vision_area.get_node("CollisionShape2D").shape = shape
	
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)
	
	# Iniciar animación
	if animated_sprite:
		animated_sprite.play("flying")
	
	# Color inicial
	_set_alert_color(color_normal)

func _physics_process(delta: float) -> void:
	# --- Movimiento ---
	if objetivo:
		var direccion = (objetivo.global_position - global_position).normalized()
		velocity = direccion * velocidad_movimiento
		last_seen_position = objetivo.global_position
		buscando = false
		patrullando = false
	elif buscando:
		var direccion = (last_seen_position - global_position).normalized()
		velocity = direccion * velocidad_busqueda
		if global_position.distance_to(last_seen_position) < 5.0:
			buscando = false
			patrullando = true
	else:
		# Patrulla aleatoria
		if patrullando:
			if punto_objetivo == Vector2.ZERO or global_position.distance_to(punto_objetivo) < 5.0:
				punto_objetivo = _obtener_punto_aleatorio()
			var direccion = (punto_objetivo - global_position).normalized()
			velocity = direccion * velocidad_patrulla
	
	# --- Mantener dentro de límites del polígono ---
	if area_limite and area_limite.has_node("CollisionPolygon2D"):
		var polygon = area_limite.get_node("CollisionPolygon2D").polygon
		var bounds = _get_polygon_bounds(polygon)
		var next_pos = global_position + velocity * delta
		next_pos.x = clamp(next_pos.x, bounds.position.x + margen_limite, bounds.position.x + bounds.size.x - margen_limite)
		next_pos.y = clamp(next_pos.y, bounds.position.y + margen_limite, bounds.position.y + bounds.size.y - margen_limite)
		global_position = next_pos
	
	move_and_slide()
	
	# --- Disparo automático ---
	if objetivo and puede_disparar:
		disparar()

# --- Función de disparo ---
func disparar() -> void:
	if projectil_scene and objetivo:
		puede_disparar = false
		fire_timer.start()
		
		var proyectil_instance = projectil_scene.instantiate()
		get_tree().current_scene.add_child(proyectil_instance)
		
		proyectil_instance.global_position = firing_point.global_position
		
		if proyectil_instance.has_method("set_target"):
			proyectil_instance.set_target(objetivo.global_position)
		elif proyectil_instance.has_method("set_direction"):
			var dir_disparo = (objetivo.global_position - firing_point.global_position).normalized()
			proyectil_instance.set_direction(dir_disparo)
		
		print("Dron dispara!")

# --- Señales del área de visión ---
func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		objetivo = body as CharacterBody2D
		_set_alert_color(color_alerta)
		print("Jugador detectado!")

func _on_vision_area_body_exited(body: Node2D) -> void:
	if objetivo == body:
		objetivo = null
		buscando = true
		patrullando = false
		_set_alert_color(color_normal)
		fire_timer.stop()
		puede_disparar = true
		print("Jugador fuera de rango, buscando...")

# --- Timeout del disparo ---
func _on_fire_timer_timeout() -> void:
	puede_disparar = true

# --- Cambiar color de alerta ---
func _set_alert_color(color: Color) -> void:
	if alert_shape:
		if alert_shape.has_method("set_modulate"):
			alert_shape.modulate = color
		elif alert_shape.has_method("set_color"):
			alert_shape.color = color
		elif alert_shape.has_property("modulate"):
			alert_shape.modulate = color

# --- Generar punto aleatorio dentro del polígono ---
func _obtener_punto_aleatorio() -> Vector2:
	if area_limite and area_limite.has_node("CollisionPolygon2D"):
		var polygon = area_limite.get_node("CollisionPolygon2D").polygon
		var bounds = _get_polygon_bounds(polygon)
		var x = randf_range(bounds.position.x + margen_limite, bounds.position.x + bounds.size.x - margen_limite)
		var y = randf_range(bounds.position.y + margen_limite, bounds.position.y + bounds.size.y - margen_limite)
		return Vector2(x, y)
	return global_position

# --- Obtener límites del polígono ---
func _get_polygon_bounds(polygon: PackedVector2Array) -> Rect2:
	if polygon.size() == 0:
		return Rect2(0, 0, 0, 0)
	
	var min_point = polygon[0]
	var max_point = polygon[0]
	
	for point in polygon:
		min_point.x = min(min_point.x, point.x)
		min_point.y = min(min_point.y, point.y)
		max_point.x = max(max_point.x, point.x)
		max_point.y = max(max_point.y, point.y)
	
	return Rect2(min_point, max_point - min_point)
