extends CharacterBody3D

@export var move_speed: float = 10.0
@export var vertical_speed: float = 6.0
@export var mouse_sensitivity: float = 0.15
@export var interact_distance: float = 40.0  

var _mouse_captured: bool = true
var _yaw: float = 0.0
var _pitch: float = 0.0

var current_target = null              
var was_interact_pressed: bool = false  
var was_unir_pressed: bool = false
var was_verificar_pressed: bool = false

@onready var cam: Camera3D = null
@onready var selector: RayCast3D = null
@onready var ui_hint: Label = null

var unir_button: Button = null
var verificar_button: Button = null


func _ready():
	add_to_group("player")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_mouse_captured = true

	cam = get_node_or_null("Camera3D")
	if cam == null:
		cam = _find_camera_recursive(self)

	selector = get_node_or_null("Selector")
	if selector == null:
		push_warning("⚠ No se encontró un RayCast3D llamado 'Selector' como hijo del jugador.")

	ui_hint = get_tree().get_first_node_in_group("hint_label")

	# Botones de UI
	unir_button = get_tree().get_first_node_in_group("unir_button")
	if unir_button != null:
		unir_button.pressed.connect(_on_unir_button_pressed)

	verificar_button = get_tree().get_first_node_in_group("verificar_button")
	if verificar_button != null:
		verificar_button.pressed.connect(_on_verificar_button_pressed)

	_yaw = rotation.y
	if cam:
		_pitch = cam.rotation.x


func _unhandled_input(event):
	
	if event is InputEventMouseMotion and _mouse_captured:
		_yaw -= event.relative.x * mouse_sensitivity * 0.01
		_pitch -= event.relative.y * mouse_sensitivity * 0.01

		_pitch = clamp(_pitch, deg_to_rad(-60.0), deg_to_rad(60.0))

		rotation.y = _yaw
		if cam:
			cam.rotation.x = _pitch

	
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_mouse_captured = not _mouse_captured
		if _mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_unite_current_target()


func _physics_process(delta):
	
	var input_dir = Vector3.ZERO

	var forward = 0.0
	var right = 0.0

	if Input.is_key_pressed(KEY_D):
		forward += 1.0
	if Input.is_key_pressed(KEY_A):
		forward -= 1.0
	if Input.is_key_pressed(KEY_S):
		right += 1.0
	if Input.is_key_pressed(KEY_W):
		right -= 1.0

	var up = 0.0
	if Input.is_key_pressed(KEY_SPACE):
		up += 1.0
	if Input.is_key_pressed(KEY_CTRL):
		up -= 1.0

	input_dir += -transform.basis.z * forward
	input_dir += transform.basis.x * right

	var vel = Vector3.ZERO
	if input_dir.length() > 0.001:
		vel += input_dir.normalized() * move_speed

	vel.y = up * vertical_speed
	velocity = vel
	move_and_slide()

	
	_update_target_and_ui()

	
	_update_dynamic_cable()

	
	var pressing_e = Input.is_key_pressed(KEY_E)
	if pressing_e and not was_interact_pressed:
		_try_unite_current_target()
	was_interact_pressed = pressing_e

	
	var pressing_u = Input.is_key_pressed(KEY_U)
	if pressing_u and not was_unir_pressed:
		_on_unir_button_pressed()
	was_unir_pressed = pressing_u

	
	var pressing_v = Input.is_key_pressed(KEY_V)
	if pressing_v and not was_verificar_pressed:
		_on_verificar_button_pressed()
	was_verificar_pressed = pressing_v


func _update_target_and_ui() -> void:
	
	current_target = null

	
	var nearest: Area3D = null
	var best_dist := interact_distance

	var buildings = get_tree().get_nodes_in_group("building")
	for b in buildings:
		if not (b is Area3D):
			continue
		var pos: Vector3
		if b.has_method("get_connection_point"):
			pos = b.get_connection_point()
		else:
			pos = b.global_transform.origin

		var d = global_transform.origin.distance_to(pos)
		if d <= interact_distance and d < best_dist:
			best_dist = d
			nearest = b

	current_target = nearest

	
	if ui_hint == null:
		return

	if current_target != null:
		var w = 0
		if "weight" in current_target:
			w = current_target.weight
		ui_hint.visible = true
		ui_hint.text = "Nodo %d (w=%d)  -  [E/U] UNIR, clic o botón" % [current_target.node_id, w]
	else:
		ui_hint.visible = false


func _update_dynamic_cable() -> void:
	var gm = get_tree().get_first_node_in_group("graph_manager")
	var drawer = get_tree().get_first_node_in_group("line_drawer")
	if gm == null or drawer == null:
		return
	if not gm.has_method("get_last_building"):
		return
	var last_building = gm.get_last_building()
	if last_building == null:
		return

	var from_pos: Vector3
	if last_building.has_method("get_connection_point"):
		from_pos = last_building.get_connection_point()
	else:
		from_pos = last_building.global_transform.origin

	var to_pos: Vector3 = global_transform.origin
	if drawer.has_method("update_dynamic_cable"):
		drawer.update_dynamic_cable(from_pos, to_pos)


func _try_unite_current_target() -> void:
	if current_target == null:
		return

	print("✔ Uniendo con nodo", current_target.node_id)

	var gm = get_tree().get_first_node_in_group("graph_manager")
	if gm and gm.has_method("register_visit"):
		gm.register_visit(current_target)


func _on_unir_button_pressed() -> void:
	_try_unite_current_target()


func _on_verificar_button_pressed() -> void:
	var gm = get_tree().get_first_node_in_group("graph_manager")
	if gm and gm.has_method("verify_solution"):
		gm.verify_solution()


func _get_building_from_collider(collider):
	var node = collider
	while node != null and node is Node:
		if node.is_in_group("building") and node is Area3D:
			return node
		node = node.get_parent()
	return null


func _find_camera_recursive(node):
	for child in node.get_children():
		if child is Camera3D:
			return child
		var found = _find_camera_recursive(child)
		if found:
			return found
	return null
