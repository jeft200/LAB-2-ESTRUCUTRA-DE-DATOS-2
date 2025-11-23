extends Area2D

@export var costo: int = 10
@export var nombre_camino: String = "Camino"
@export var mostrar_costo_al_acercarse: bool = false

var ya_cobrado: bool = false
var label_costo: Label = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Crear label para mostrar el costo (opcional)
	if mostrar_costo_al_acercarse:
		crear_label_costo()

func crear_label_costo():
	label_costo = Label.new()
	label_costo.text = "$" + str(costo)
	label_costo.add_theme_font_size_override("font_size", 24)
	label_costo.add_theme_color_override("font_color", Color.YELLOW)
	label_costo.position = Vector2(-20, -40)
	label_costo.visible = false
	add_child(label_costo)

func _on_body_entered(body):
	if body.name == "Jugador":
		# Mostrar costo si está configurado
		if label_costo and not ya_cobrado:
			label_costo.visible = true
		
		# Cobrar si no se ha cobrado
		if not ya_cobrado:
			cobrar_al_jugador()

func _on_body_exited(body):
	if body.name == "Jugador":
		# Ocultar label
		if label_costo:
			label_costo.visible = false
		
		# Permitir cobrar de nuevo después de un tiempo
		await get_tree().create_timer(0.5).timeout
		ya_cobrado = false

func cobrar_al_jugador():
	ya_cobrado = true
	
	var laberinto = get_parent().get_parent()
	
	if laberinto and laberinto.has_method("cobrar_costo"):
		laberinto.cobrar_costo(costo, nombre_camino)
		
		# Efecto visual de cobro
		if label_costo:
			animar_cobro()

func animar_cobro():
	# Animación simple del label
	var tween = create_tween()
	tween.tween_property(label_costo, "position:y", label_costo.position.y - 30, 0.5)
	tween.parallel().tween_property(label_costo, "modulate:a", 0.0, 0.5)
	await tween.finished
	label_costo.position.y += 30
	label_costo.modulate.a = 1.0
