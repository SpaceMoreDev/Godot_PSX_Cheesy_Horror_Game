extends Node3D

class_name AI

enum MOVESTATES
{
	IDLE,
	COMMUTING,
	CHASING,
	STUNNED
}

var _current_movement : MOVESTATES = MOVESTATES.IDLE
var target_destination : Vector3 # location the AI will follow (should be able to be cancelled midway)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	match _current_movement:
		MOVESTATES.IDLE:
			pass
		MOVESTATES.COMMUTING:
			pass
		MOVESTATES.CHASING:
			pass
