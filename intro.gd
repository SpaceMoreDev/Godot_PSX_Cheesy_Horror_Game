extends Node2D

@export var dialogue_to_start : DialogueResource
@export var intro_seq : int :
	get:
		return GlobalData.dialogue_sequence

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	DialogueManager.show_dialogue_balloon(dialogue_to_start, "start")
