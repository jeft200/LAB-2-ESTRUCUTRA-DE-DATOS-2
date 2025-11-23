extends Node2D # Ahora extiende Node2D como lo solicitaste.

@export var required_key: String = "llave2"   # Ejemplo: "KeyBlue"
@export var next_scene: String = "res://Escenas/Nivel2.tscn"

# Referencias a nodos hijos. ¡Asegúrate de que existan y estén nombrados correctamente!
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_label: Label = $InteractLabel
@onready var detection_area: Area2D = $DetectionArea # <-- ¡NUEVO! Referencia al Area2D hijo

var is_player_near := false


func _ready() -> void:
	# Conectar las señales del Area2D hijo a las funciones de este script padre.
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)
	else:
		# ¡Importante! Si no se encuentra DetectionArea, el script no funcionará correctamente.
		push_error("ERROR: No se encontró el nodo 'DetectionArea' como hijo de este Node2D. ¡Necesario para la detección!")

	interact_label.visible = false


# ---------------------------------------------------------------------
# CUANDO EL JUGADOR ENTRA EN EL ÁREA DE DETECCIÓN (DEL NODO HIJO)
# ---------------------------------------------------------------------
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_near = true
		interact_label.text = "[E] Interactuar"
		interact_label.visible = true


# ---------------------------------------------------------------------
# CUANDO EL JUGADOR SALE DEL ÁREA DE DETECCIÓN (DEL NODO HIJO)
# ---------------------------------------------------------------------
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_near = false
		interact_label.visible = false


# ---------------------------------------------------------------------
# TECLA E PARA ABRIR → CAMBIO DE ESCENA
# ---------------------------------------------------------------------
func _process(_delta: float) -> void:
	if is_player_near and Input.is_action_just_pressed("ui_accept"):
		_try_open()


# ---------------------------------------------------------------------
# LÓGICA PRINCIPAL: INTENTAR ABRIR/CAMBIAR DE ESCENA
# ---------------------------------------------------------------------
func _try_open():
	if required_key == "":
		_go_to_next_level()
		return

	if Global and Global.has_key(required_key):
		_go_to_next_level()
	else:
		print("La puerta/salida está cerrada. Falta la llave:", required_key)
		# Opcional: Proporcionar feedback visual/sonoro de que está bloqueado.
		# interact_label.text = "¡BLOQUEADO! Necesitas " + required_key


# ---------------------------------------------------------------------
# CAMBIO DE ESCENA
# ---------------------------------------------------------------------
func _go_to_next_level():
	print("Cambiando a:", next_scene)
	if ResourceLoader.exists(next_scene, "PackedScene"):
		get_tree().change_scene_to_file(next_scene)
	else:
		print("ERROR: La escena '" + next_scene + "' no se encontró o no es válida.")
