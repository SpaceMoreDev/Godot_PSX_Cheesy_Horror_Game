extends CharacterBody3D
class_name Enemy

enum State {
	MOVE,
	HIT,
	WAIT
}

const STRAFE_DISTANCE := 100.0

const SPEED := 5.0
const JUMP_VELOCITY := 4.5

var player: MovementController

@export var target_ik: Node3D
@onready var AnimTree : AnimationTree = $AnimationTree
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var ik: SkeletonIK3D = $C1/Armature/Skeleton3D/SkeletonIK3D

var hair_offset := Vector3.ZERO

var state := State.MOVE
var wait_timer := 0.0

var new_velocity : Vector3 = Vector3.ZERO
var is_hit : bool = false
var shooting_timer : float = 0.1
var remapped_vel : float

func _ready() -> void:
	player = GlobalData.Player

	if target_ik:
		ik.target_node = target_ik.get_path()
		ik.start()

		hair_offset = to_local(target_ik.global_position)

	pick_new_position()

var shooting_timer_counter : float = 0.0
func _physics_process(delta: float) -> void:
	var player_look_dir := (-player.camera.global_transform.basis.z).normalized()
	var forward_dir := -transform.basis.z
	update_ik(delta)
	remapped_vel = remap(velocity.length(), 0.00, 10.00, 0.00, 1.00)
	
	match state:
		State.HIT:
			Hit()
			return
		State.MOVE:
			update_move_state(delta)
		State.WAIT:
			update_wait_state(delta)
		
	if state != State.MOVE and player_look_dir.dot(forward_dir) > 0.99:
		state = State.MOVE
		pick_new_position()
		update_move_state(delta)
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

	if shooting_timer_counter < shooting_timer:
		shooting_timer_counter += delta
	else:
		shoot()
		shooting_timer_counter = 0


func update_move_state(delta: float) -> void:
	# NavigationAgent movement only
	var next_pos := nav.get_next_path_position()

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
	if nav.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0

		state = State.WAIT
		wait_timer = randf_range(0.5, 10.0)

		#shoot()


func update_wait_state(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0

	# Look at player while waiting
	var look_dir := (player.global_position - global_position).normalized()

	var angle := atan2(look_dir.x, look_dir.z)

	rotation.y = lerp_angle(
		rotation.y,
		angle,
		delta * 5.0
	)

	wait_timer -= delta

	if wait_timer <= 0.0:
		pick_new_position()
		state = State.MOVE

var reachct = 0
func pick_new_position() -> void:
	var radius := randf_range(3.0, 6.0)
	var angle := randf_range(0.0, TAU)

	var offset := Vector3(
		cos(angle),
		0.0,
		sin(angle)
	) * radius
	nav.target_position = player.global_position + offset
	


func update_ik(delta: float) -> void:
	if not target_ik:
		return

	var target_pos := to_global(hair_offset)

	target_ik.look_at(player.global_position, Vector3.UP)

	target_ik.global_position = target_ik.global_position.lerp(
		target_pos,
		delta * SPEED
	)

var hit_wait : float = 0.1
var hit_wait_ct : float = 0.0
var shooter 
var shot_angle : float

func Hit():
	if hit_wait_ct< hit_wait:
		hit_wait_ct += get_process_delta_time()
		rotation.y = shot_angle
	else:
		is_hit = false
		
		
		hit_wait_ct = 0
		state = State.WAIT

func _is_Hit(shooter : Vector3):
	var shooterdir = shooter - global_position
	var angle := atan2(shooterdir.x, shooterdir.z)
	
	
	shot_angle = angle
	hit_wait_ct = 0
	is_hit = true
	
	velocity = Vector3.ZERO
	nav.target_position = global_position 
	state = State.HIT


func shoot() -> void:
	print("Shoot")
