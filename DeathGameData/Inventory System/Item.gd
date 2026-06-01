extends Resource
class_name  Item 

@export var id : int
@export var item_name : String
@export var effect_factor : float
@export var model : PackedScene

@export var preview_offset: Vector3 = Vector3.ZERO
@export var preview_rotation: Vector3

func activate():
	pass 
