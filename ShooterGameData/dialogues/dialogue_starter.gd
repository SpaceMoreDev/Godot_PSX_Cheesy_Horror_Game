extends Node

@export var dialogue_to_start : DialogueResource

func _ready() -> void:
	if dialogue_to_start:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		DialogueManager.show_dialogue_balloon(dialogue_to_start, "start", [self])

func _end_level():
	GlobalData.ChangetoScene(1)
