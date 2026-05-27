extends Node

class_name WorldEvents

enum LOOPSTATE{
	OUT,
	IN
}

@export var timer_factor = 5

var event_timer : Timer
var _state : LOOPSTATE = LOOPSTATE.OUT

func _ready() -> void:
	event_timer = Timer.new()
	add_child(event_timer)
	event_timer.start(timer_factor)
	event_timer.timeout.connect(time_advance)

func time_advance():
	print("time advanced")

func SetState(new_state : LOOPSTATE)->LOOPSTATE:
	_state = new_state
	return _state

func GetState()->LOOPSTATE:
	return _state
