extends CharacterBody3D

class_name AI

enum MOVESTATES
{
	MOVE,
	HIT,
	WAIT
}

enum BEHAVIORSTATES
{
	CHASE,
	LOOKING,
	NEUTRAL
}

var _player: MovementController
var _current_movement : MOVESTATES = MOVESTATES.WAIT
var _target_destination : Vector3 # location the AI will follow (should be able to be cancelled midway)
var _nav: NavigationAgent3D
var _wait_timer := 0.0

const SPEED := 5.0


func _ready() -> void:
	_nav = NavigationAgent3D.new()
	add_child(_nav)
	
	_player = GlobalData.Player
	
	pick_new_random_position_in_radius()

func pick_new_random_position_in_radius() -> void:
	if !_nav: return
	
	var radius := randf_range(3.0, 6.0)
	var angle := randf_range(0.0, TAU)

	var offset := Vector3(
		cos(angle),
		0.0,
		sin(angle)
	) * radius
	_nav.target_position = _player.global_position + offset
	

func _physics_process(delta: float) -> void:
	
	var player_look_dir := (-_player.camera.global_transform.basis.z).normalized() # to look at player constantly while moving!
	var forward_dir := -transform.basis.z
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	
func update_move_state(delta: float) -> void:
	# NavigationAgent movement only
	var next_pos := _nav.get_next_path_position()
	var dir := (next_pos - global_position).normalized()

	velocity = Vector3(
		dir.x * SPEED,
		velocity.y,
		dir.z * SPEED
	)

	# Rotate toward movement
	if dir.length() > 0.01:
		var angle := atan2(dir.x, dir.z)

		rotation.y = lerp_angle(
			rotation.y,
			angle,
			delta * 5.0
		)

	# Destination reached
	if _nav.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0

		_current_movement = MOVESTATES.WAIT
		_wait_timer = randf_range(0.5, 10.0)

		#shoot()
func _on_move_states():
	match _current_movement:
		MOVESTATES.WAIT:
			pass
		MOVESTATES.HIT:
			pass
		MOVESTATES.MOVE:
			pass
