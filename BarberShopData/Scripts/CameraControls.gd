extends Camera3D
class_name BarberControl

@export_node_path("BarberCore") var core_pass = NodePath("../")
#@onready var core : BarberCore = get_node(core_pass)

@export var target : Node3D
var vec_to_tar : Vector3 = Vector3.ZERO

const SPEED : float = 5.0
var _is_dragging = false
var _drag_vector := Vector2.ZERO
var sensitivity := 2
var _received_mouse_motion := false
var can_drag:=false
var _zoom : float = 0.0
var _zoom_factor : float = 0.1
var offset : Vector3 = Vector3.ZERO

func _input(event: InputEvent) -> void:
	_zoom = 0.0
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			_zoom = -_zoom_factor
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			_zoom = _zoom_factor
		
		var zoomed_dir =(global_position - target.global_position).normalized() * _zoom
		if (offset.normalized()).dot((offset + zoomed_dir).normalized()) > 0.80:
			offset += zoomed_dir
			
		
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			if event.is_pressed() :
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
	vec_to_tar = global_position - target.global_position
	offset = global_position - target.global_position

var anglex := 0.0
var angley := 0.0
func _physics_process(delta: float) -> void:
	anglex = -_drag_vector.x * delta
	angley = -_drag_vector.y * delta
	
	var pivot = target.global_position
	
	offset = offset.rotated(Vector3.UP, anglex)
	
	offset = offset.rotated(transform.basis.x, angley)
	var new_dir =pivot + offset
	
	global_position = new_dir 
	
	look_at(pivot)
	


func _on_area_3d_mouse_entered() -> void:
	can_drag = true

func _on_area_3d_mouse_exited() -> void:
	can_drag = false
