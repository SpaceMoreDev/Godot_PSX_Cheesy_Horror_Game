extends Control
class_name inventory

@export var initial_inventory_items : Dictionary [Item, int]
var _inventory_items : Array[Item]
@export var slot_scene : PackedScene

var _inventory_slots : Array[Inv_Slot]
var active : bool = false
var _current_slot : Inv_Slot
var _current_item : Item
var _current_slot_index : int = 0
# todo:
# items array. (done)
# add, remove items from the inventory. (done)
# action function for each item. (maybe an interface?)
# cool looking UI for inventory system where items float in 3D.

func _next_item():
		_inventory_slots[_current_slot_index].is_active = false
		_current_slot_index = (_current_slot_index + 1) % _inventory_slots.size()
		_inventory_slots[_current_slot_index].is_active = true
		_current_slot = _inventory_slots[_current_slot_index]

func _previous_item():
		_inventory_slots[_current_slot_index].is_active = false
		_current_slot_index = (_current_slot_index - 1 + _inventory_slots.size()) % _inventory_slots.size()
		_inventory_slots[_current_slot_index].is_active = true
		_current_slot = _inventory_slots[_current_slot_index]

func _number_switch(event: InputEvent):
	var key_num := -1

	match event.keycode:
		KEY_1: key_num = 0
		KEY_2: key_num = 1
		KEY_3: key_num = 2
		KEY_4: key_num = 3
		KEY_5: key_num = 4
		KEY_6: key_num = 5
		KEY_7: key_num = 6
		KEY_8: key_num = 7
		KEY_9: key_num = 8

	if key_num >= 0 and key_num < _inventory_slots.size():
		select_slot(key_num)

func select_slot(index: int) -> void:
	if index == _current_slot_index:
		return

	_inventory_slots[_current_slot_index].is_active = false

	_current_slot_index = index

	_inventory_slots[_current_slot_index].is_active = true
	_current_slot = _inventory_slots[_current_slot_index]

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		show_inventory()
		print("show")
	elif Input.is_action_just_released("inventory"):
		hide_inventory()
		print("hide")

	
	if event is InputEventKey:
		if event.pressed:
			_number_switch(event)
		
		if !active: return
		
		if Input.is_action_just_pressed("inventory_next"):
			_next_item()
		
		elif Input.is_action_just_pressed("inventory_previous"):
			_previous_item()
	if event is InputEventMouseButton:
		if Input.is_action_pressed("inventory_next"):
			_next_item()
		
		elif Input.is_action_pressed("inventory_previous"):
			_previous_item()
	
func _ready() -> void:
	$HBoxContainer.visible = false
	initialize_inventory()
	pass

func add_item(_item : Item):
	var duplicate_item = _item.duplicate(true)
	duplicate_item.resource_local_to_scene = true
	_inventory_items.append(duplicate_item)
	
	var slot : Inv_Slot = slot_scene.instantiate()
	$HBoxContainer.add_child(slot)
	
	slot.set_data(duplicate_item)
	
	_inventory_slots.append(slot)
	

func remove_item(_item : Item):
	_inventory_items.erase(_item)
	
	for i in _inventory_slots:
		if i.inv_item == _item:
			_inventory_slots.erase(i)
			i.queue_free()

func clear_inventory():
	_inventory_items.clear()
	
	for i in _inventory_slots:
		i.queue_free()
	_inventory_slots.clear()

func get_first_of(type_id : int) -> Item: # should get first item of type X in array.
	for x in _inventory_items:
		if x.id == type_id:
			return x
	return null

func use_item(item_id : int): # if item of type exists, activate then remove 
	var _item_to_use = get_first_of(item_id)
	if _item_to_use:
		_item_to_use.activate()
		remove_item(_item_to_use)

func print_inventory():
	var counts := {}

	for item: Item in _inventory_items:
		if !counts.has(item.id):
			counts[item.id] = {
				"item": item,
				"count": 0
			}

		counts[item.id]["count"] += 1

	print("====================================")
	print("| ID   | Item Name        | Qty    |")
	print("====================================")

	for id in counts:
		var data = counts[id]
		var item: Item = data["item"]

		print("| %-4d | %-16s | %-6d |" % [
			item.id,
			item.item_name,
			data["count"]
		])

	print("====================================")

func initialize_inventory():
	for x  in initial_inventory_items:
		if x:
			var ct = initial_inventory_items[x]
			while ct > 0:
				add_item(x)
				ct-=1
	
	print_inventory()

func show_inventory():
	active = true
	$HBoxContainer.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($HBoxContainer, "position", Vector2(148.0, 473.0), 0.3).set_ease(Tween.EASE_IN)
	tween.finished.connect(shown)
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property($HBoxContainer, "scale", Vector2.ONE, 0.3)
	

func hide_inventory():
	active = false
	
	if _current_slot:
		_current_item = _current_slot.inv_item
		
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property($HBoxContainer, "position", Vector2(148.0, 800.0), 0.3)
	tween_pos.finished.connect(hidden)
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property($HBoxContainer, "scale", Vector2(0.5,0.5), 0.3)

func shown():
	_inventory_slots[_current_slot_index].is_active=true
	print("shown")
func hidden():
	$HBoxContainer.visible = false
	_inventory_slots[_current_slot_index].is_active=false
	print("hidden")
