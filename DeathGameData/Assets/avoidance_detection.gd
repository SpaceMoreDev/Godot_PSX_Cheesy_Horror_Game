extends Node3D
class_name AI_Avoidance_Detection

@export var _ray_forward : RayCast3D
@export var _ray_left : RayCast3D
@export var _ray_right : RayCast3D

signal on_avoidance(direction : Vector3)

var is_avoiding : bool = false

func _ready():
    _ray_forward.enabled = true
    _ray_left.enabled = true
    _ray_right.enabled = true

    _ray_forward.collide_with_areas = true
    _ray_left.collide_with_areas = true
    _ray_right.collide_with_areas = true

    #print("Avoidance Detection ready with rays: ", _ray_forward, _ray_left, _ray_right)

func _physics_process(delta):
    if _ray_forward.is_colliding():
        print(_ray_forward.get_collider().name + " detected in front!")
        _on_avoidance(Vector3.FORWARD)
    elif _ray_left.is_colliding():
        print(_ray_left.get_collider().name + " detected on the left!")
        _on_avoidance(Vector3.LEFT)
    elif _ray_right.is_colliding():
        print(_ray_right.get_collider().name + " detected on the right!")
        _on_avoidance(Vector3.RIGHT)
    else:
        is_avoiding = false

func _on_avoidance(direction : Vector3):
   on_avoidance.emit(direction)
   is_avoiding = true
