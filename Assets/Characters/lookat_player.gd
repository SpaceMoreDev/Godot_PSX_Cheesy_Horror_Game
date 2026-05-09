extends Node3D

var player : MovementController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GlobalData.Player

func _process(delta: float) -> void:
	look_at(player.global_position);
