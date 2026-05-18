extends Node3D

@export var control : BarberControl
var material : Material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material = $"../Area3D/Head/Hair".get_surface_override_material(0)

var is_drag := false
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if $Cuttter.visible:
			is_drag = true
	

func _process(delta: float) -> void:
	if Input.is_action_pressed("firing"):
		if material:
				material.set_shader_parameter(\
					"brush_position",\
					global_position \
				)
		if is_drag:
			$CPUParticles3D.emitting = true
	
	else:
		$CPUParticles3D.emitting = false
		
	
	is_drag = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = control.project_ray_origin(mousepos)
	var end = origin + control.project_ray_normal(mousepos) * 5000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	if result:
		if not $Cuttter.visible:
			global_position = result.position
			$Cuttter.visible = true
			
		
		var up = result.normal.normalized()
		var forward = Vector3.UP
		
		var right = up.cross(forward).normalized()
		
		if right.is_zero_approx():
			right = Vector3.RIGHT
		
		forward = right.cross(up).normalized()
		var basis = Basis(right, up , forward)
		
		global_basis = lerp(global_basis, basis, 10 *delta)
		global_scale(Vector3.ONE)
		global_position = lerp(global_position, result.position, 10 *delta) 
	else:
		if $Cuttter.visible:
			$Cuttter.visible = false
			
