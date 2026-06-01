extends Control
class_name inventory

@export var initial_inventory_items : Dictionary [Item, int]
var _inventory_items : Array[Item]
@export var slot_scene : PackedScene

var _inventory_slots : Array[Inv_Slot]
var active : bool = false
var _current_slot : Inv_Slot
var _current_item : Item
var _current_slot_index : int = -1
# todo:
# items array. (done)
# add, remove items from the inventory. (done)
# action function for each item. (maybe an interface?)
# cool looking UI for inventory system where items float in 3D.

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("inventory"):
			if active:
				hide_inventory()
				print("hide")
			else:
				show_inventory()
				print("show")
	
	if !active: return
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("inventory_next"):
			_inventory_slots[_current_slot_index].is_active = false

			_current_slot_index = (_current_slot_index + 1) % _inventory_slots.size()

			_inventory_slots[_current_slot_index].is_active = true
			_current_slot = _inventory_slots[_current_slot_index]

		elif Input.is_action_just_pressed("inventory_previous"):
			#if _current_slot_index<_inventory_slots.size():
			_inventory_slots[_current_slot_index].is_active = false

			_current_slot_index = (_current_slot_index - 1 + _inventory_slots.size()) % _inventory_slots.size()

			_inventory_slots[_current_slot_index].is_active = true
			_current_slot = _inventory_slots[_current_slot_index]

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
	tween.tween_property($HBoxContainer, "position", Vector2(148.0, 473.0), 0.1).set_ease(Tween.EASE_IN)

func hide_inventory():
	active = false
	_current_slot.is_active=false
	_current_slot_index = -1
	var tween = get_tree().create_tween()
	tween.tween_property($HBoxContainer, "position", Vector2(148.0, 800.0), 0.1)
	tween.finished.connect(hidden)

func hidden():
	$HBoxContainer.visible = false
	print("hidden")
