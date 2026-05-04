extends Node

class_name AnimController

@export var sway_factor : float = 0.1
@export_node_path("MovementController") var controller_path := NodePath("../")
@onready var controller: MovementController = get_node(controller_path)
@export_node_path("Node3D") var hand_path := NodePath("../Head/Hand")
@onready var hand: Node3D = get_node(hand_path)

@export_node_path("AnimationTree") var anim_path := NodePath("../Head/Hand/SMG_GUN/AnimationTree")
@onready var AnimTree: AnimationTree = get_node(anim_path)

func _process(delta: float) -> void:
	var global_forward = -controller.global_basis.z

	if !is_zero_approx(int(controller.input_axis.length())):
		
		if controller.input_axis.x > 0.0:
			hand.position.z =lerp(hand.position.z, sway_factor, 5*delta)
		else :
			hand.position.z =lerp(hand.position.z, -sway_factor, 5*delta)
		
		if controller.input_axis.y > 0.0:
			hand.position.x =lerp(hand.position.x, -(sway_factor/2), 5*delta)
		else :
			hand.position.x =lerp(hand.position.x, (sway_factor/2), 5*delta)
	else:
		hand.position.x =lerp(hand.position.x, 0.0, 5*delta)
		hand.position.z =lerp(hand.position.z, 0.0, 5*delta)

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
