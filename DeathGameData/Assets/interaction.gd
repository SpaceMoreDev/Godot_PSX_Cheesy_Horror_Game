extends Node3D
class_name P_Interaction

var can_interact:bool:
	set(val):
		controller.is_interacting = val
		if CHSprite:
			if val == false:
				CHSprite.play("default")
			else:
				CHSprite.play("interact")
	get:
		return controller.is_interacting

const RAY_LENGTH = 1000
@export_node_path("AnimatedSprite2D") var Crosshair_path := NodePath("../CanvasLayer/Center/CrosshairSprite")
@onready var CHSprite : AnimatedSprite2D = get_node(Crosshair_path)

@export_node_path("MovementController") var c_path := NodePath("../")
@onready var controller: MovementController = get_node(c_path)

@export_node_path("Head") var head_path := NodePath("../Head")
@onready var cam: Camera3D = get_node(head_path).cam


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	if result:
		var obj :Node3D = result.collider
			
		if obj is Interactable:
			#if not can_interact:
				#can_interact = true
			if Input.is_action_just_pressed("interact"):
				obj.Interact()
			
			
	#else:
		#if can_interact:
				#can_interact = false
