extends Node3D

var lines: Array = []                
var dynamic_line: MeshInstance3D = null 


func _ready():
	add_to_group("line_drawer")


func clear_all() -> void:
	for l in lines:
		if is_instance_valid(l):
			l.queue_free()
	lines.clear()

	if dynamic_line != null and is_instance_valid(dynamic_line):
		dynamic_line.queue_free()
	dynamic_line = null


func _create_line_mesh(from_local: Vector3, to_local: Vector3) -> ImmediateMesh:
	var mesh := ImmediateMesh.new()
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(from_local)
	mesh.surface_add_vertex(to_local)
	mesh.surface_end()
	return mesh


func _create_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	return mat


func update_dynamic_cable(from_world: Vector3, to_world: Vector3) -> void:
	var from_local: Vector3 = to_local(from_world)
	var to_local_pos: Vector3 = to_local(to_world)

	var mesh := _create_line_mesh(from_local, to_local_pos)

	if dynamic_line == null or not is_instance_valid(dynamic_line):
		dynamic_line = MeshInstance3D.new()
		add_child(dynamic_line)
	dynamic_line.mesh = mesh
	dynamic_line.material_override = _create_material(Color(1.0, 0.9, 0.1)) # amarillo


func clear_dynamic_cable() -> void:
	if dynamic_line != null and is_instance_valid(dynamic_line):
		dynamic_line.queue_free()
	dynamic_line = null


func draw_connection(building_a: Area3D, building_b: Area3D) -> void:
	if building_a == null or building_b == null:
		return

	var world_from: Vector3
	if building_a.has_method("get_connection_point"):
		world_from = building_a.get_connection_point()
	else:
		world_from = building_a.global_transform.origin

	var world_to: Vector3
	if building_b.has_method("get_connection_point"):
		world_to = building_b.get_connection_point()
	else:
		world_to = building_b.global_transform.origin


	var from_local: Vector3 = to_local(world_from)
	var to_local_pos: Vector3 = to_local(world_to)

	var mesh := _create_line_mesh(from_local, to_local_pos)

	var line_instance := MeshInstance3D.new()
	line_instance.mesh = mesh
	line_instance.material_override = _create_material(Color(0.1, 1.0, 0.1)) # verde

	add_child(line_instance)
	lines.append(line_instance)
