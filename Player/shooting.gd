extends Node3D

enum GunType
{
	Pistol,
	Rifle,
	Shotgun
}

var bullet_count : int = 30
var bullet_pool : Array[Fire]

const RAY_LENGTH = 1000

@export var shoot_type : GunType = GunType.Pistol

@export_node_path("Head") var head_path := NodePath("../../")
var head: Head
var controller: MovementController
var cam: Camera3D

# Preload your decal scene
const BULLET_DECAL = preload("res://decal.tscn")

var is_shooting : bool :
	set(val):
		if controller:
			controller.is_shooting = val
	get:
		if controller:
			return controller.is_shooting
		return false

@export_node_path("AnimatedSprite2D") var Crosshair_path := NodePath("../../../CanvasLayer/Center/CrosshairSprite")
@onready var CHSprite : AnimatedSprite2D = get_node(Crosshair_path)
func _enter_tree() -> void:
	head = get_node(head_path)
	controller = head.controller
	cam = head.cam

func _ready() -> void:
	var ct = 0
	while ct < bullet_count:
		var new_bullet : Fire= BULLET_DECAL.instantiate()
		get_tree().root.add_child.call_deferred(new_bullet)
		new_bullet.stop()
		bullet_pool.append(new_bullet)
		ct+=1

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
		
		var collider = result.collider
		
		if collider is Enemy:
			collider._is_Hit(global_position)

func _spawn_decal(result): # will use pooling
	var collision_point = result.position
	var collision_normal = result.normal
	var decal : Fire = _get_from_pool()
	
	if not decal:
		return
	
	
	
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
	
	decal.global_position = collision_point
	var tar = result.collider
	if tar is CharacterBody3D:
		decal.activate( Fire.FIRE_TYPE.BLOOD, basis)
	else:
		decal.activate( Fire.FIRE_TYPE.FIRE, basis)
	

func _get_from_pool() -> Fire:
	for i in bullet_pool:
		if !i.active:
			return i
	return null

func _input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
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
	if !cam: return
	
	if zoomed_in:
		cam.set_fov(lerp(cam.fov, 20.0, delta * 8))
	else:
		cam.set_fov(lerp(cam.fov, 60.0, delta * 8))
	
