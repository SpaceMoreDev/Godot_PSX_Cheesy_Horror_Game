extends Node

@export var Player : MovementController

func _ready() -> void:
	Player = get_tree().get_first_node_in_group("Player") as MovementController
