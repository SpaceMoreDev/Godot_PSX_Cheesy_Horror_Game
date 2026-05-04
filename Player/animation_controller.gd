extends Node

class_name AnimController


@export_node_path("MovementController") var controller_path := NodePath("../")
@onready var controller: MovementController = get_node(controller_path)


@export_node_path("AnimationTree") var anim_path := NodePath("../Head/AnimationTree")
@onready var AnimTree: AnimationTree = get_node(anim_path)

func _physics_process(delta: float) -> void:
	var remapped_vel : float = remap(controller.velocity.length(),0.0,17.0,0.0,1.0)
	#print("velocity: %f" % remapped_vel)
	
	if Input.is_action_just_pressed("aiming"):
		AnimTree.is_aiming = true
	if Input.is_action_just_released("aiming"):
		AnimTree.is_aiming = false
	
	if Input.is_action_just_pressed("firing"):
		AnimTree.is_firing = true
	if Input.is_action_just_released("firing"):
		AnimTree.is_firing = false
	
	
	if controller.is_on_floor():
		AnimTree.is_grounded = true
		AnimTree.set("parameters/StateMachine/Movement/move_blend/blend_position" , remapped_vel)
	else:
		AnimTree.is_grounded = false
