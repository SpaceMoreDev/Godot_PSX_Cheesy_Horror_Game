extends Node

class_name AnimController


@export_node_path("MovementController") var controller_path := NodePath("../")
@onready var controller: MovementController = get_node(controller_path)


@export_node_path("AnimationTree") var anim_path := NodePath("../Head/AnimationTree")
@onready var AnimTree: AnimationTree = get_node(anim_path)

func _physics_process(delta: float) -> void:
	var remapped_vel : float = remap(controller.velocity.length(),0.0,17.0,0.0,1.0)
	print("velocity: %f" % remapped_vel)
	
	if controller.is_on_floor():
		AnimTree.set("parameters/movement/move_blend/blend_position" , remapped_vel)
	
