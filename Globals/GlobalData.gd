extends Node

@export var Player : MovementController
@export var personality = 0
@export var dialogue_sequence := 0
var levels : Array[String] = [
	"res://Intro.tscn",
	"res://Levels/Main/L_Main.tscn"
]

func ChangetoScene(index : int):
	if levels[index]:
		get_tree().change_scene_to_file(levels[index])
	else:
		printerr("!!!wrong level index!!!")
