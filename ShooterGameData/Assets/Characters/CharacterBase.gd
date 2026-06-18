extends CharacterBody3D
class_name CharacterBase

var health : float = 100

func damage_health(val):
	health -= val
