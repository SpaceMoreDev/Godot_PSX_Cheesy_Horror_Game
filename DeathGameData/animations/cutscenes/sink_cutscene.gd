extends Interactable

class_name cutscene

@onready var animation_loc : Vector3 = $anim_loc.global_position
@onready var player = GlobalData.Player

@export var animation_to_play : String

func _interact_action():
	super()
	if player:

		player.canmove = false
		player.can_look = false

		var final_pos = Vector3(animation_loc.x, player.global_position.y, animation_loc.z)
		var direction = (global_position - final_pos ).normalized()

		player.rotation.y = atan2(direction.x,-direction.z)
		player.player_anim.play(animation_to_play)

		get_tree().create_tween().tween_property(player,"global_position",final_pos,.05)
