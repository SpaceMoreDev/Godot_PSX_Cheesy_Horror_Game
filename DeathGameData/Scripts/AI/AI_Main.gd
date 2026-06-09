extends CharacterBody3D
class_name AI_Main


enum AISTATES
{
	MOVING,
	IDLE,
	STUNNED,
	ALERTED
}


var _state : AISTATES = AISTATES.IDLE

var _stun_duration : float = 2.0
var _stun_timer : Timer
var _state_timer : Timer
var _nav : NavigationAgent3D


@export var _ai_data : AIData
@export var _animation_player : AnimationPlayer

func _ready():

	if _ai_data == null:
		_ai_data = AIData.new()
		add_child(_ai_data)


	_nav = NavigationAgent3D.new()
	add_child(_nav)

	_nav.avoidance_enabled = true
	_nav.radius = 0.5
	_nav.max_speed = _ai_data.move_speed
	_nav.debug_enabled = true
	_nav.velocity_computed.connect(_on_nav_velocity_computed)
	_nav.navigation_finished.connect(_on_navigation_finished)

	_nav.path_desired_distance = 1.5
	_nav.target_desired_distance = 1.0

	print("navigation ready: ", _nav)

	_stun_timer = Timer.new()
	add_child(_stun_timer)
	_stun_timer.wait_time = _stun_duration
	_stun_timer.one_shot = true

	_state_timer = Timer.new()
	add_child(_state_timer)
	_state_timer.wait_time = 1.0
	_state_timer.autostart = true
	_state_timer.timeout.connect(_on_state_timer_timeout)

	if _animation_player == null:
		_animation_player = AnimationPlayer.new()
		add_child(_animation_player)


func _set_destination(destination: Vector3):
	if _nav != null:
		_nav.set_target_position(destination)

func _on_state_timer_timeout():
	print("+ State timer timeout, current state: ", _state)
	match _state:
		AISTATES.IDLE:
			SWITCH_STATE(AISTATES.IDLE)
		AISTATES.MOVING:
			SWITCH_STATE(AISTATES.MOVING)

func _physics_process(delta: float) -> void:
	match _state:
		AISTATES.MOVING:
			update_move_state(delta)
		AISTATES.IDLE:
			update_idle_state(delta)
		AISTATES.STUNNED:
			update_stunned_state(delta)
		AISTATES.ALERTED:
			update_alerted_state(delta)


func update_move_state(delta: float) -> void:
	
	var speed = _ai_data.move_speed
	#get next direct point in path
	var next_point = _nav.get_next_path_position()
	var direction = (next_point - global_position).normalized() * speed

	#velocity = direction * _ai_data.move_speed
	var _nav_velocity = Vector3(direction.x, velocity.y, direction.z) 
	_ai_data.curr_velocity = _nav_velocity.length()

	_nav.set_velocity(_nav_velocity)
	
	apply_floor_snap()


func _on_nav_velocity_computed(suggested_velocity: Vector3):
	
	#get next direct point in path
	velocity = velocity.move_toward(suggested_velocity, 0.67)

	var direction = (suggested_velocity)

	if direction.length() > 0.01:
		var angle := atan2(direction.x, direction.z)

		rotation.y = lerp_angle(
			rotation.y,
			angle,
			get_physics_process_delta_time() * 5.0
		)
		
	move_and_slide()


func _on_navigation_finished():
	print("Navigation finished, reached destination")
	SWITCH_STATE(AISTATES.IDLE)
	velocity.x = 0.0
	velocity.z = 0.0
	
func update_idle_state(delta: float) -> void:
	_ai_data.curr_velocity = 0.0

func update_stunned_state(delta: float) -> void:
	pass

func update_alerted_state(delta: float) -> void:
	pass


func SWITCH_STATE(state : AISTATES):
	match state: # This is where you can add any logic that should happen when switching to a new state
		AISTATES.MOVING:
			print("state set to moving")
		AISTATES.IDLE:
			print("state set to idle")
		AISTATES.STUNNED:
			print("state set to stunned")
		AISTATES.ALERTED:
			print("state set to alerted")

	if _ai_data != null:
		_ai_data.current_state = state

	_state = state

   
