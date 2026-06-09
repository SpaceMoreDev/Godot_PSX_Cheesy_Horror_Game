extends Node
class_name AIData


@export var current_state : AI_Main.AISTATES =  AI_Main.AISTATES.IDLE
@export var move_speed : float = 2.0
var curr_velocity : float = 0.0

@export var animation_tree : AnimationTree
var temp_vel := 0.0
func _process(delta: float) -> void:
	if animation_tree != null:
		temp_vel = lerp(temp_vel, curr_velocity, delta * 10)
		animation_tree["parameters/StateMachine/Movement/blend_position"] = temp_vel
