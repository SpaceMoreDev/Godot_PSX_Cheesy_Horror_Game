extends Camera3D
class_name BarberCamera

@export_node_path("BarberCore") var core_pass = NodePath("../")
@onready var core : BarberCore = get_node(core_pass)

@export var target : Node3D
var vec_to_tar : Vector3 = Vector3.ZERO

const SPEED : float = 5.0
var _is_dragging = false
var _drag_vector := Vector2.ZERO
var sensitivity := 0.1
var _received_mouse_motion := false
var can_drag:=false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.is_pressed() and can_drag:
				_is_dragging = true
			elif event.is_released():
				_is_dragging = false
				_drag_vector = Vector2.ZERO
	if event is InputEventMouseMotion and _is_dragging:
		var mousedelta = event.relative * sensitivity
		_received_mouse_motion = true
		_drag_vector = mousedelta

func _process(delta: float) -> void:
	if !_received_mouse_motion:
		_drag_vector = Vector2.ZERO

	_received_mouse_motion = false

func _ready() -> void:
	vec_to_tar = target.global_position - global_position


var anglex := 0.0
var angley := 0.0
func _physics_process(delta: float) -> void:
	anglex = -_drag_vector.x * delta
	angley = -_drag_vector.y * delta
	
	var pivot = target.global_position
	
	var offset = global_position - pivot
	
	offset = offset.rotated(Vector3.UP, anglex)
	
	offset = offset.rotated(transform.basis.x, angley)
	var new_dir =pivot + offset
	
	global_position = new_dir
	
	look_at(pivot)


func _on_area_3d_mouse_entered() -> void:
	can_drag = true

func _on_area_3d_mouse_exited() -> void:
	can_drag = false
