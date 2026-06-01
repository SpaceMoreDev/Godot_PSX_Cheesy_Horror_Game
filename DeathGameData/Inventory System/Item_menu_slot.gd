extends Control

class_name Inv_Slot

@export var inv_item : Item
var is_hovering : bool = false

var _active : bool = false

var is_active : bool :
	get: return _active
	set(val):
		if val:
			activate()
		else:
			deactivate()
		_active = val
var item_mesh : MeshInstance3D
var item_model : Node3D

@onready var viewport := $Subview
@onready var model := $Subview/Preview/Model
@onready var texture_rect := $TextureRect
@export_file_path() var path_to_overlay_material 

var item_slot_overlay_mat : ShaderMaterial

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	texture_rect.texture = viewport.get_texture()
	item_slot_overlay_mat = ResourceLoader.load("res://DeathGameData/Inventory System/m_UI_Item_Selection.tres", "ShaderMaterial", ResourceLoader.CACHE_MODE_IGNORE)
	print(viewport.get_instance_id())

	if inv_item:
		set_data(inv_item)

func set_data(new_item : Item):
	if !new_item: return
	
	inv_item = new_item

	$Name.text = inv_item.item_name
	
	item_model = inv_item.model.instantiate()
	if item_model:
		model.add_child(item_model)
		
		item_model.position = inv_item.preview_offset
		item_model.rotation_degrees = inv_item.preview_rotation
		
		item_mesh = item_model.get_child(0)
		
		item_mesh.material_overlay = item_slot_overlay_mat
		item_mesh.material_overlay.set_shader_parameter("selection_amount", 1.0)
		
		#call_deferred("deselect")

func _process(delta: float) -> void:
	model.rotate_y(delta)


func _on_mouse_entered() -> void:
	activate()

func _on_mouse_exited() -> void:
	deactivate()

func activate():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.1)
	
	if item_mesh:
		#item_mesh.material_overlay.set_shader_parameter("selection_amount", 0.0)
		select()


func deactivate():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	
	if item_mesh:
		#item_mesh.material_overlay.set_shader_parameter("selection_amount", 1.0)
		deselect()


var selection_tween : Tween

func select():
	if selection_tween:
		selection_tween.kill()
	
	selection_tween = create_tween()
	selection_tween.tween_property(
		item_mesh.material_overlay,
		"shader_parameter/selection_amount",
		0.0,
		0.2
	)

func deselect():
	if selection_tween:
		selection_tween.kill()
	
	selection_tween = create_tween()
	selection_tween.tween_property(
		item_mesh.material_overlay,
		"shader_parameter/selection_amount",
		1.0,
		0.2
	)
