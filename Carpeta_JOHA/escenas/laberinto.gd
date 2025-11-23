extends StaticBody2D

# Referencias a los nodos
@onready var player = $Jugador
@onready var label_dinero = $CanvasLayer/panel/VBoxContainer/LabelDinero
@onready var label_costo = $CanvasLayer/panel/VBoxContainer/LabelCosto
@onready var label_tiempo = $CanvasLayer/panel/VBoxContainer/LabelTiempo

# Variables del juego
var dinero_inicial: int = 112
var dinero_actual: int = 112
var costo_total: int = 0
var tiempo_restante: float = 120.0  # 2 minutos = 120 segundos
var mision_activa: bool = true
var mision_completada: bool = false
var panel_layer: CanvasLayer = null

# Camino óptimo teórico (ajusta según tu laberinto)
var costo_optimo: int = 250

func _ready():
	print("=== MISIÓN 2: LABERINTO DIJKSTRA ===")
	print("Objetivo: Llega a la meta con el menor costo")
	print("Tiempo límite: 2 minutos")
	actualizar_ui()

func _process(delta):
	if not mision_activa:
		return
	
	# Actualizar temporizador
	tiempo_restante -= delta
	
	# Actualizar UI del tiempo
	var minutos = int(tiempo_restante) / 60
	var segundos = int(tiempo_restante) % 60
	label_tiempo.text = "Tiempo: %d:%02d" % [minutos, segundos]
	
	# Cambiar color según tiempo restante
	if tiempo_restante < 30:
		label_tiempo.add_theme_color_override("font_color", Color.RED)
	elif tiempo_restante < 60:
		label_tiempo.add_theme_color_override("font_color", Color.YELLOW)
	
	# Verificar si se acabó el tiempo
	if tiempo_restante <= 0:
		tiempo_agotado()

func cobrar_costo(costo: int, nombre: String):
	
	if not mision_activa:
		return
	
	costo_total += costo
	dinero_actual = dinero_inicial - costo_total
	
	print("Pasaste por camino ", nombre, " - Costo: $", costo)
	print("Dinero restante: $", dinero_actual)
	
	# Verificar si se quedó sin dinero
	if dinero_actual <= 0:
		dinero_actual = 0
		actualizar_ui()
		sin_dinero()  # Nueva función
		return
	
	actualizar_ui()

func actualizar_ui():
	label_dinero.text = "Dinero: $" + str(dinero_actual)
	label_costo.text = "Costo: $" + str(costo_total)
	
	# Cambiar color del dinero según la cantidad
	if dinero_actual <= 0:
		label_dinero.add_theme_color_override("font_color", Color.RED)
	elif dinero_actual < 20:
		label_dinero.add_theme_color_override("font_color", Color.RED)
		# Hacer parpadear el texto cuando está crítico
		hacer_parpadear_dinero()
	elif dinero_actual < 50:
		label_dinero.add_theme_color_override("font_color", Color.ORANGE)
	else:
		label_dinero.add_theme_color_override("font_color", Color.GREEN)

func hacer_parpadear_dinero():
	# Crear animación de parpadeo
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(label_dinero, "modulate:a", 0.3, 0.3)
	tween.tween_property(label_dinero, "modulate:a", 1.0, 0.3)
func _on_objetivo_alcanzado():
	if mision_completada:
		return
	
	mision_completada = true
	mision_activa = false
	
	print("¡OBJETIVO ALCANZADO!")
	mostrar_resultado()

func tiempo_agotado():
	mision_activa = false
	print("¡TIEMPO AGOTADO!")
	mostrar_resultado_tiempo_agotado()

func sin_dinero():
	mision_activa = false
	print("¡TE QUEDASTE SIN DINERO!")
	
	# Detener al jugador
	if player:
		player.set_physics_process(false)
	
	# Mostrar panel de game over
	mostrar_resultado_sin_dinero()
	
func mostrar_resultado_sin_dinero():
	# Crear un CanvasLayer para que esté fijo en la pantalla
	panel_layer = CanvasLayer.new()
	panel_layer.layer = 100
	get_tree().root.add_child(panel_layer)
	
	# Crear panel de resultado
	var panel = PanelContainer.new()
	panel.position = Vector2(460, 200)  # Centrado en pantalla 1152x648
	panel.custom_minimum_size = Vector2(400, 300)
	panel_layer.add_child(panel)

	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Título
	var titulo = Label.new()
	titulo.text = "¡SIN DINERO!"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color.RED)
	vbox.add_child(titulo)
	
	# Espacio
	var spacer1 = Control.new()
	spacer1.custom_minimum_size.y = 20
	vbox.add_child(spacer1)
	
	# Mensaje
	var mensaje = Label.new()
	mensaje.text = "Te quedaste sin dinero\nantes de llegar a la meta"
	mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mensaje.add_theme_font_size_override("font_size", 18)
	vbox.add_child(mensaje)
	
	# Espacio
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 20
	vbox.add_child(spacer2)
	
	# Estadísticas
	var stats = Label.new()
	var tiempo_usado = 120 - int(tiempo_restante)
	var minutos = tiempo_usado / 60
	var segundos = tiempo_usado % 60
	
	stats.text = "Costo gastado: $%d\nTiempo usado: %d:%02d" % [
		costo_total,
		minutos,
		segundos
	]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 16)
	stats.add_theme_color_override("font_color", Color.ORANGE)
	vbox.add_child(stats)
	
	# Espacio
	var spacer3 = Control.new()
	spacer3.custom_minimum_size.y = 20
	vbox.add_child(spacer3)
	
	# Botón reintentar
	var boton = Button.new()
	boton.text = "Reintentar"
	boton.custom_minimum_size = Vector2(200, 50)
	boton.pressed.connect(_on_reintentar_pressed)
	vbox.add_child(boton)
func mostrar_resultado():
	# Crear un CanvasLayer para que esté fijo en la pantalla
	panel_layer = CanvasLayer.new()
	panel_layer.layer = 100
	get_tree().root.add_child(panel_layer)
	
	# Crear panel de resultado
	var panel = PanelContainer.new()
	panel.position = Vector2(460, 150)  # Centrado en pantalla
	panel.custom_minimum_size = Vector2(400, 350)
	panel_layer.add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Título
	var titulo = Label.new()
	titulo.text = "¡MISIÓN COMPLETADA!"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", Color.GREEN)
	vbox.add_child(titulo)
	
	# Espacio
	var spacer1 = Control.new()
	spacer1.custom_minimum_size.y = 20
	vbox.add_child(spacer1)
	
	# Estadísticas
	var stats = Label.new()
	var tiempo_usado = 120 - int(tiempo_restante)
	var minutos = tiempo_usado / 60
	var segundos = tiempo_usado % 60
	
	stats.text = "Costo Total: $%d\nCosto Óptimo: $%d\nTiempo: %d:%02d\nDinero Restante: $%d" % [
		costo_total, 
		costo_optimo, 
		minutos, 
		segundos,
		dinero_actual
	]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 18)
	vbox.add_child(stats)
	
	# Espacio
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 20
	vbox.add_child(spacer2)
	
	# Evaluación
	var evaluacion = Label.new()
	var texto_eval = evaluar_desempeno()
	evaluacion.text = texto_eval
	evaluacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	evaluacion.add_theme_font_size_override("font_size", 20)
	
	if costo_total <= costo_optimo:
		evaluacion.add_theme_color_override("font_color", Color.GREEN)
	elif costo_total <= costo_optimo * 1.5:
		evaluacion.add_theme_color_override("font_color", Color.YELLOW)
	else:
		evaluacion.add_theme_color_override("font_color", Color.ORANGE)
	
	vbox.add_child(evaluacion)
	
	# Espacio
	var spacer3 = Control.new()
	spacer3.custom_minimum_size.y = 20
	vbox.add_child(spacer3)
	
	# Botón continuar
	var boton = Button.new()
	boton.text = "Continuar"
	boton.custom_minimum_size = Vector2(200, 50)
	boton.pressed.connect(_on_continuar_pressed)
	vbox.add_child(boton)

func mostrar_resultado_tiempo_agotado():
	# Crear un CanvasLayer para que esté fijo en la pantalla
	
	panel_layer = CanvasLayer.new()
	panel_layer.layer = 100
	get_tree().root.add_child(panel_layer)

	
	var panel = PanelContainer.new()
	panel.position = Vector2(460, 220)  # Centrado en pantalla
	panel.custom_minimum_size = Vector2(400, 200)
	panel_layer.add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var titulo = Label.new()
	titulo.text = "¡TIEMPO AGOTADO!"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", Color.RED)
	vbox.add_child(titulo)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	vbox.add_child(spacer)
	
	var mensaje = Label.new()
	mensaje.text = "No llegaste al objetivo a tiempo.\nIntenta nuevamente."
	mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mensaje.add_theme_font_size_override("font_size", 18)
	vbox.add_child(mensaje)
	
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 20
	vbox.add_child(spacer2)
	
	var boton = Button.new()
	boton.text = "Reintentar"
	boton.custom_minimum_size = Vector2(200, 50)
	boton.pressed.connect(_on_reintentar_pressed)
	vbox.add_child(boton)

func evaluar_desempeno() -> String:
	if costo_total <= costo_optimo:
		return "★★★ ¡ÓPTIMO!\nEncontraste el mejor camino"
	elif costo_total <= costo_optimo * 1.3:
		return "★★ MUY BIEN\nCamino cercano al óptimo"
	elif costo_total <= costo_optimo * 1.5:
		return "★ BIEN\nPuedes mejorar"
	else:
		return "REGULAR\nIntenta encontrar un camino más barato"

func _on_continuar_pressed():
	# Destruir el panel antes de cambiar de escena
	if panel_layer:
		panel_layer.queue_free()
	
	# Despausar el juego si estaba pausado
	get_tree().paused = false
	
	# Volver a la sala principal
	get_tree().change_scene_to_file("res://Carpeta_JOHA/escenas/mapa.tscn")

func _on_reintentar_pressed():
	# Destruir el panel antes de reiniciar
	if panel_layer:
		panel_layer.queue_free()
	
	# Despausar el juego si estaba pausado
	get_tree().paused = false
	
	# Reiniciar la misión
	get_tree().reload_current_scene()
