extends Control

# --- REFERENCIAS ---
@onready var contenedor_salas = $Control
@onready var contenedor_lineas = $Node2D

# --- COLORES HDR ---
var color_apagado = Color(0, 0.2, 0, 1)
var color_actual = Color(0, 4.5, 0, 1)
var color_rastro = Color(0, 1.5, 0, 1)

# Variable local temporal
var sala_anterior: String = ""

func _ready():
	print("[MiniMapa] Iniciando. Restaurando memoria desde Global...")
	resetear_visuales()
	
	# --- AQUÍ ESTÁ LA MAGIA: RESTAURAR ESTADO ANTERIOR ---
	restaurar_estado()

func registrar_paso(nombre_nueva_sala: String):
	if nombre_nueva_sala == "": return
	
	# Sincronizamos la variable local con la global por si acabamos de cambiar de escena
	if sala_anterior == "":
		sala_anterior = Global.ultima_sala

	# SI ES EL PRIMER PASO DEL JUEGO TOTAL
	if Global.ultima_sala == "":
		actualizar_global_sala(nombre_nueva_sala)
		iluminar_nodo(nombre_nueva_sala, true)
		sala_anterior = nombre_nueva_sala
		return

	# SI NOS MOVEMOS A OTRA SALA
	if sala_anterior != nombre_nueva_sala:
		# 1. Visuales
		iluminar_nodo(sala_anterior, false)       # La vieja se apaga un poco
		pintar_linea(sala_anterior, nombre_nueva_sala) # Pintamos cable
		iluminar_nodo(nombre_nueva_sala, true)    # La nueva brilla
		
		# 2. Guardar en Global (MEMORIA PERMANENTE)
		actualizar_global_sala(nombre_nueva_sala)
		actualizar_global_conexion(sala_anterior, nombre_nueva_sala)
		
		# 3. Actualizar local
		sala_anterior = nombre_nueva_sala

# --- FUNCIONES DE GESTIÓN DE DATOS (GLOBAL) ---

func restaurar_estado():
	# 1. Volver a pintar todas las salas viejas
	for sala in Global.salas_visitadas:
		iluminar_nodo(sala, false) # Color rastro
	
	# 2. Volver a pintar todas las líneas viejas
	for conexion in Global.conexiones_pintadas:
		# conexion es un string tipo "A-B". Buscamos esa línea.
		var linea = contenedor_lineas.get_node_or_null(conexion)
		# A veces guardamos A-B pero el nodo se llama B-A, probamos ambos
		if not linea:
			var partes = conexion.split("-") # Separar "A" y "B"
			if partes.size() == 2:
				linea = contenedor_lineas.get_node_or_null(partes[1] + "-" + partes[0])
		
		if linea:
			linea.default_color = color_rastro
			linea.width = 4.0
			
	# 3. Iluminar la última sala donde nos quedamos (Actual)
	if Global.ultima_sala != "":
		iluminar_nodo(Global.ultima_sala, true)
		sala_anterior = Global.ultima_sala

func actualizar_global_sala(sala: String):
	Global.ultima_sala = sala
	if not sala in Global.salas_visitadas:
		Global.salas_visitadas.append(sala)

func actualizar_global_conexion(desde: String, hasta: String):
	# Guardamos el nombre de la conexión para repintarla luego
	var n1 = desde.replace("Sala", "")
	var n2 = hasta.replace("Sala", "")
	var nombre_conexion = n1 + "-" + n2
	
	if not nombre_conexion in Global.conexiones_pintadas:
		Global.conexiones_pintadas.append(nombre_conexion)

# --- FUNCIONES VISUALES (Idénticas a antes) ---

func iluminar_nodo(nombre: String, es_actual: bool):
	var nodo = contenedor_salas.get_node_or_null(nombre)
	if nodo:
		if es_actual:
			nodo.color = color_actual
			nodo.scale = Vector2(1.2, 1.2)
			nodo.z_index = 1
		else:
			nodo.color = color_rastro
			nodo.scale = Vector2(1.0, 1.0)
			nodo.z_index = 0

func pintar_linea(desde: String, hasta: String):
	var n1 = desde.replace("Sala", "")
	var n2 = hasta.replace("Sala", "")
	var linea = contenedor_lineas.get_node_or_null(n1 + "-" + n2)
	if not linea: linea = contenedor_lineas.get_node_or_null(n2 + "-" + n1)
	
	if linea:
		linea.default_color = color_rastro
		linea.width = 4.0

func resetear_visuales():
	for sala in contenedor_salas.get_children():
		if sala is ColorRect: sala.color = color_apagado
	for linea in contenedor_lineas.get_children():
		if linea is Line2D: linea.default_color = color_apagado
