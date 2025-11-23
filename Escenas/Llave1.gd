extends Area2D
class_name KeyItem

# Nombre del item que se asignará al jugador
var key_item_name: String = ""

func _ready() -> void:
	# Conectar la señal de detección del jugador
	self.body_entered.connect(_on_key_body_entered)
	# Asignar automáticamente el nombre de la llave según el nivel y recorrido global
	_asignar_nombre_llave()

func _asignar_nombre_llave():
	var nivel = Global.nivel_actual
	var tipo_recorrido = Global.algoritmo_seleccionado

	match nivel:
		1:
			key_item_name = "Llave B"
		2:
			key_item_name = "Llave C"
		3:
			key_item_name = "Llave D" if tipo_recorrido == "BFS" else "Llave E"
		4:
			key_item_name = "Llave E" if tipo_recorrido == "BFS" else "Llave D"
		5:
			key_item_name = "Llave E" if tipo_recorrido == "DFS" else "-"

	print("✅ Llave asignada para Nivel ", nivel, ": ", key_item_name)

func _on_key_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		print("¡Jugador recogió la llave: ", key_item_name, "!")

		if body.has_method("set_held_item"):
			body.set_held_item(key_item_name)
		else:
			print("ADVERTENCIA: El jugador no tiene el método 'set_held_item'.")

		# Incrementar nivel global automáticamente
		Global.nivel_actual += 1
		print("➡️ Nivel actualizado a: ", Global.nivel_actual)

		# La llave desaparece del mundo
		queue_free()
