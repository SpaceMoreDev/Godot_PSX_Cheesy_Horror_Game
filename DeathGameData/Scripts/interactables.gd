extends Node3D
class_name Interactable

enum INTERACTIONS{
	ACTION,
	DIALOGUE,
	MINIGAME
}

var _interaction_type : INTERACTIONS = INTERACTIONS.ACTION

var _dialogue : DialogueResource
var _minigame : Node3D
func Interact():
	match _interaction_type:
		INTERACTIONS.ACTION:
			_interact_action()
		INTERACTIONS.DIALOGUE:
			_interact_dialogue(_dialogue)
		INTERACTIONS.MINIGAME:
			_interact_minigame(_minigame)

func _interact_action():
	print("interacted!")
	pass

func _interact_dialogue(dialogue : DialogueResource):
	pass

func _interact_minigame(minigame : Node3D):
	pass
