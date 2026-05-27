extends CanvasLayer
@export var dialogue : DialogueResource

func _ready() -> void:
	#GlobalData.Player.canmove = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#DialogueManager.show_dialogue_balloon(dialogue, "start", [self])
	#await DialogueManager.dialogue_ended
	#GlobalData.Player.canmove = true
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func _start_fade():
	$AnimationPlayer.play("fadein")
