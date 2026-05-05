extends Area3D

@export var diaLabel : DialogueLabel

@export var dialogue_to_start : DialogueResource

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	

func _on_body_enter(body):
	if body is CharacterBody3D:
		print("hey there handsome!")
		GlobalData.Player.canmove = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		DialogueManager.show_dialogue_balloon(dialogue_to_start, "start")
		await DialogueManager.dialogue_ended
		GlobalData.Player.canmove = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		print("hey there non-handsome!")
