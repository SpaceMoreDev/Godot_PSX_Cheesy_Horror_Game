extends Node3D
class_name Fire

var fires : Array[AnimatedSprite3D]


enum FIRE_TYPE
{
	FIRE,
	BLOOD
}

var active = false

func _ready() -> void:
	for child in get_children():
		fires.append(child)
		child.visible = false
		child.animation_finished.connect(stop)

func stop():
	for i in fires:
		i.visible = false
	active = false


func activate(type : FIRE_TYPE = FIRE_TYPE.FIRE, new_basis : Basis = Basis()):
	global_basis = new_basis
	active = true
	
	for i in fires:
		i.visible = true
		match type:
			FIRE_TYPE.FIRE:
				i.play("fire")
				global_scale(Vector3.ONE)
			FIRE_TYPE.BLOOD:
				i.play("blood")
				global_scale(Vector3.ONE * 1.2)
