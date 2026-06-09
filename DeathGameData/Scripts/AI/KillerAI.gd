extends AI_Main
class_name KillerAI

var _player: MovementController
const SPEED := 2.0

func _ready():
	super()
	_player = GlobalData.Player

func _physics_process(delta: float) -> void:
	super(delta)
	if Input.is_action_just_pressed("debug_follow"):
		if _player:
			var player_position := _player.global_transform.origin
			_set_destination(player_position)
			SWITCH_STATE(AISTATES.MOVING)
