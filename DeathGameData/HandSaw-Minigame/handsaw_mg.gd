extends Node3D

@onready var _progess_bar : ProgressBar = $CanvasLayer/Control/ProgressBar
@onready var _win_boxes : HBoxContainer = $CanvasLayer/Control/required_wins
var _win_boxes_array : Array[Control]


@export var difficulty : float = 2 # the higher the harder 
@export var num_wins : int = 3
@export var _wins : int = 1
var _strength :float = 10

var completed : bool = false

func _ready() -> void:
	for i in _win_boxes.get_children():
		if i.get_index() > 0:
			i.visible = false
		_win_boxes_array.append(i)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_progess_bar.value += _strength

var new_progress_val : float = 0
func _process(delta: float) -> void:
	if completed: return
	
	if is_equal_approx(_progess_bar.value, _progess_bar.max_value):
		if _wins >= num_wins:
			completed = true
			print("completed!!")
			return
		
		if _wins < _win_boxes_array.size():
			_win_boxes_array[_wins].visible = true
		_wins +=1
		_strength -= difficulty
		new_progress_val = 0
		_progess_bar.value = 0
	
	new_progress_val -= 1;
	new_progress_val = clamp(new_progress_val, _progess_bar.min_value, _progess_bar.max_value)
	
	_progess_bar.value = lerp(_progess_bar.value, new_progress_val,  delta)
	
	
