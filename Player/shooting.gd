extends Node3D

enum GunType
{
	Pistol,
	Rifle,
	Shotgun
}

const RAY_LENGTH = 1000

@export var shoot_type : GunType = GunType.Pistol

@export_node_path("Camera3D") var head_path := NodePath("../../Camera")
@onready var cam: Camera3D = get_node(head_path)
# Preload your decal scene
const BULLET_DECAL = preload("res://decal.tscn")
var is_shooting : bool = false

func FIRE():
	if !is_shooting:
		return
	
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		_spawn_decal(result)

func _spawn_decal(result): # will use pooling
	var collision_point = result.position
	var collision_normal = result.normal
	var decal = BULLET_DECAL.instantiate()
	
	get_tree().root.add_child(decal)

	decal.global_position = collision_point
	#decal.get_node("AnimatedSprite3D").play()
	#decal.get_node("AnimatedSprite3D2").play()
	var rng = RandomNumberGenerator.new()


	var up = collision_normal.normalized()
	var forward = Vector3.UP
	
	var right = up.cross(forward).normalized()
	if right.is_zero_approx():
		right = Vector3.RIGHT
	
	forward = right.cross(up).normalized()
	var basis = Basis(right, up , forward)

	
	var random_angle = rng.randf_range(0.0, TAU)
	basis = Basis(up, random_angle) * basis

	decal.global_basis = basis

	await get_tree().create_timer(1).timeout
	decal.queue_free()
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("firing"):
		is_shooting = true
	if Input.is_action_just_released("firing"):
		is_shooting = false
	
	if Input.is_action_just_pressed("aiming"):
		zoomed_in = true
	if Input.is_action_just_released("aiming"):
		zoomed_in = false
		#cam.fov = 60;

var zoomed_in = false
func _physics_process(delta: float) -> void:
	if zoomed_in:
		cam.set_fov(lerp(cam.fov, 20.0, delta * 8))
	else:
		cam.set_fov(lerp(cam.fov, 60.0, delta * 8))
	
