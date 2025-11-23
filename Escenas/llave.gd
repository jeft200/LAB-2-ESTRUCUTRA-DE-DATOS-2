extends Area2D

@export var nombre_sala_manual: String = "" 
var key_item_name: String = ""

func _ready() -> void:
	# 1. CONECTAR LA SEÑAL CORRECTAMENTE (Esto arregla que no la coja)
	# Usamos connect de forma segura apuntando a la función de abajo
	body_entered.connect(_on_body_entered)
	
	# 2. LÓGICA INTELIGENTE (DFS/BFS y Nombre de Sala)
	configurar_llave()

func configurar_llave():
	# A) Detectar sala (Padre)
	var nombre_contenedor = nombre_sala_manual
	if nombre_contenedor == "":
		nombre_contenedor = get_parent().name # Ej: "SalaB"
	
	# B) Detectar algoritmo
	var algoritmo = "BFS"
	if Global.get("algoritmo_seleccionado"):
		algoritmo = Global.algoritmo_seleccionado
	
	# C) Decidir nombre de la llave
	key_item_name = obtener_nombre_llave(nombre_contenedor, algoritmo)
	
	# D) Verificar si ya la tenemos (Para borrarla si ya la cogimos)
	if Global.get("llaves_recogidas") != null:
		if key_item_name in Global.llaves_recogidas:
			queue_free() # Ya la tienes, borrar del mundo
			return
			
	if key_item_name == "":
		queue_free() # Esta sala no lleva llave
	else:
		print("Llave lista en ", nombre_contenedor, ": ", key_item_name)

# --- LÓGICA MATEMÁTICA ---
func obtener_nombre_llave(sala: String, tipo: String) -> String:
	match sala:
		"SalaA": return "llave B"
		"SalaB": return "llave C"
		"SalaC": return "llave D" if tipo == "BFS" else "llave E"
		"SalaD": return "llave E" if tipo == "BFS" else ""
		"SalaE": return "llave D" if tipo == "DFS" else ""
		_: return ""

# --- ESTA ES LA FUNCIÓN QUE SE EJECUTA AL TOCAR ---
func _on_body_entered(body: Node2D) -> void:
	# Verificamos si es el Player (por nombre o grupo)
	if body.name == "Player" or body.is_in_group("Player"):
		print("¡Jugador recogió la llave: ", key_item_name, "!")

		# 1. Dar al jugador
		if body.has_method("set_held_item"):
			body.set_held_item(key_item_name)
		else:
			print("ERROR: El Player no tiene la función 'set_held_item'")

		# 2. Guardar en memoria Global
		if Global.get("llaves_recogidas") != null:
			Global.llaves_recogidas.append(key_item_name)

		# 3. Desaparecer
		queue_free()
