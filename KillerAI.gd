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
var _current_movement : MOVESTATES = MOVESTATES.MOVE
var _target_destination : Vector3 # location the AI will follow (should be able to be cancelled midway)
var _nav: NavigationAgent3D
var _move_timer : Timer
var _wait_timer := 1.0

var _animation_node : AnimationPlayer

const SPEED := 2.0


func _ready() -> void:
	_nav = NavigationAgent3D.new()
	add_child(_nav)
	
	_player = GlobalData.Player
	_animation_node = $Killer/AnimationPlayer
	
	_move_timer = Timer.new()
	add_child(_move_timer)
	_move_timer.autostart = true
	_move_timer.wait_time = _wait_timer
	_move_timer.timeout.connect(_timout)
	
	pick_new_random_position_in_radius()

func _timout():
	print("timer_tick")

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
	
var ct : float = _wait_timer

func _physics_process(delta: float) -> void:
	
	if ct > 0:
		ct -= delta
	else:
		pick_new_random_position_in_radius()
		ct = _wait_timer

	update_move_state(delta)

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
	
	_animation_node.play("root|Walk")
	
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
func _on_move_states(delta: float):
	match _current_movement:
		MOVESTATES.WAIT:
			pass
		MOVESTATES.HIT:
			pass
		MOVESTATES.MOVE:
			update_move_state(delta)
