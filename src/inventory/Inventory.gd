class_name Inventory
extends RefCounted

signal inventory_changed();

var size: Vector2i;

## Maps Vector2i to InventoryItemStack at that position
var _positionCache: Dictionary;
var _items: Array[InventoryItemStack];

@warning_ignore("shadowed_variable")
func _init(size: Vector2i) -> void:
	self.size = size;


func get_all_items() -> Array[InventoryItemStack]:
	return _items;


func get_all_items_by_position() -> Dictionary:
	return _positionCache;

## Attempts to add this number of item_data to this inventory without resorting.
## Returns the number of items that could NOT be added in.
func add_item(item_data: InventoryItem, count: int) -> int:
	if count <= 0:
		return 0;
	
	var starting_count: int = count;
	
	# add item to existing stacks
	for item in _find_stacks_by_id(item_data.id):
		var diff: int = min(item.data.stack_size - item.count, count);
		count -= diff;
		item.count += diff;
		
		if count == 0:
			inventory_changed.emit();
			return 0;
	
	# create new stacks
	for y in range(0, size.y - item_data.size.y + 1):
		for x in range(0, size.x - item_data.size.x + 1):
			if can_fit_item(Vector2i(x, y), item_data.size, null):
				var new_item_count = min(item_data.stack_size, count);
				
				add_item_at_position(item_data, new_item_count, Vector2i(x, y), false);
				count -= new_item_count;
				
				if count == 0:
					inventory_changed.emit();
					return 0;
	
	var rotated := Vector2i(item_data.size.y, item_data.size.x);
	for y in range(0, size.y - rotated.y + 1):
		for x in range(0, size.x - rotated.x + 1):
			if can_fit_item(Vector2i(x, y), rotated, null):
				var new_item_count = min(item_data.stack_size, count);
				
				add_item_at_position(item_data, new_item_count, Vector2i(x, y), true);
				count -= new_item_count;
				
				if count == 0:
					inventory_changed.emit();
					return 0;
	
	if starting_count != count:
		inventory_changed.emit();
	
	return count;

func add_item_at_position(item_data: InventoryItem, count: int, pos: Vector2i, rotated: bool) -> void:
	var correctly_rotated: Vector2i = item_data.size if not rotated else Vector2i(item_data.size.y, item_data.size.x);
	
	assert(can_fit_item(pos, correctly_rotated, null), "Attempting to add item that cannot fit into inventory");
	
	var new_item := InventoryItemStack.new(
			item_data,
			min(item_data.stack_size, count),
			pos,
			rotated
	);
	
	_items.push_back(new_item);
	
	for x in range(pos.x, pos.x + correctly_rotated.x):
		for y in range(pos.y, pos.y + correctly_rotated.y):
			_positionCache[Vector2i(x, y)] = new_item;
	
	inventory_changed.emit();

## Returns the number of items with given id contained in inventory.
func get_item_count(id: String) -> int:
	var count: int = 0;
	
	for item in _find_stacks_by_id(id):
		count += item.count;
	
	return count;


func take_item_count(id: String, count: int) -> bool:
	return true;


func can_fit_item(item_pos: Vector2i, item_size: Vector2i, ignoring_item: InventoryItemStack) -> bool:
	if item_pos.x < 0 or item_pos.y < 0:
		return false;
	
	if item_pos.x + item_size.x > size.x or item_pos.y + item_size.y > size.y:
		return false;
	
	var items_by_pos: Dictionary = get_all_items_by_position();
	for x in range(item_pos.x, item_pos.x + item_size.x):
		for y in range(item_pos.y, item_pos.y + item_size.y):
			var item_at_pos: InventoryItemStack = items_by_pos.get(Vector2i(x, y));
			if item_at_pos != null and item_at_pos != ignoring_item:
				return false;
	
	return true;

func _find_stacks_by_id(id: String) -> Array[InventoryItemStack]:
	var ret: Array[InventoryItemStack] = [];
	
	for item in _items:
		if item.data.id == id:
			ret.push_back(item);
	
	return ret;
