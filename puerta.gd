extends Area2D

@export var requires_key: bool = true
@export var key_item_name: String = "llave_dorada" # Llave requerida

func _ready() -> void:
	# Conectar la señal de detección
	self.body_entered.connect(_on_area_2d_body_entered)

func interact(player_node: Node) -> void:
	if requires_key:
		if player_node.has_method("get_held_item") and player_node.get_held_item() == key_item_name:
			print("¡Puerta abierta con la llave!")
			change_to_next_scene()
		else:
			print("La puerta requiere la llave: ", key_item_name)
	else:
		change_to_next_scene()

func change_to_next_scene() -> void:
	var nivel = Global.nivel_actual
	var tipo = Global.algoritmo_seleccionado
	var siguiente_escena: String = ""

	match nivel:
		2:
			siguiente_escena = "res://Escenas/Nivel2.tscn"
		3:
			siguiente_escena = "res://Escenas/Nivel3.tscn"
		4:
			if tipo == "BFS":
				siguiente_escena = "res://Escenas/Nivel4_BFS.tscn"
			else:
				siguiente_escena = "res://Escenas/Nivel4_DFS.tscn"
		5:
			if tipo == "BFS":
				siguiente_escena = "res://Escenas/Nivel5_BFS.tscn"
			else:
				siguiente_escena = "res://Escenas/Nivel5_DFS.tscn"
		6:
			siguiente_escena = "res://Escenas/Final.tscn" # Ajusta según tu flujo

	if siguiente_escena != "":
		print("Cambiando a la escena: ", siguiente_escena)
		get_tree().change_scene_to_file(siguiente_escena)
	else:
		print("ERROR: No se encontró escena para el nivel ", nivel)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		interact(body)
