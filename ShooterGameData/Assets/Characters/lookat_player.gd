extends Node3D

var player : MovementController

@export_node_path("Enemy") var parent_path := NodePath("../../../../../")
@onready var enemy: Enemy = get_node(parent_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GlobalData.Player

func _process(delta: float) -> void:
	#look_at(player.global_position, Vector3.UP, true);
	var target_transform = global_transform.looking_at(player.global_position,Vector3.UP, true)
	global_transform = global_transform.interpolate_with(target_transform, 10 * delta)
