extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const StrafeDistance = 100
var player : MovementController

func _ready() -> void:
	player = GlobalData.Player

func _physics_process(delta: float) -> void:
	var playerdir = (player.global_position - global_position).normalized()
	var playerlookdir = (-player.transform.basis.z).normalized()
	var forwarddir = (-transform.basis.z).normalized()
	var rightdir = (transform.basis.x).normalized()
	var leftdir = (-transform.basis.x).normalized()
	var space_state = get_world_3d().direct_space_state
	
	var origin = global_position
	var end = origin + forwarddir * 500
	
	velocity.x = move_toward(velocity.x, 0, delta*SPEED)
	velocity.z = move_toward(velocity.z, 0, delta*SPEED)
	
	var angle = atan2(-playerdir.x, -playerdir.z)
	
	rotation.y = lerp(rotation.y,angle, delta * SPEED)
	if is_zero_approx(velocity.length()):
		if playerlookdir.dot(forwarddir) < -0.99:
			#print("looking")
			var rightside_query = PhysicsRayQueryParameters3D.create(origin, origin + rightdir * StrafeDistance)
			var leftside_query = PhysicsRayQueryParameters3D.create(origin, origin + leftdir * StrafeDistance)
			
			var leftside_result = space_state.intersect_ray(leftside_query)
			var rightside_result = space_state.intersect_ray(rightside_query)
			
			var magL = (rightside_result.position - origin).length()
			var magR = (leftside_result.position - origin).length()
			
			if magR > magL:
				
				print("strafe left")
				velocity = leftdir * SPEED
			elif magR <= magL:
				print("strafe right")
				velocity = rightdir * SPEED
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	#var direction
	#if direction:
		#
		#velocity.z = direction.z * SPEED
	#else:
	

	move_and_slide()
