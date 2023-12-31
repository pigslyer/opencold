class_name Inventory
extends RefCounted
## Represents the low level data portion of a single grid based inventory.


## Emitted when any item was added or removed from this inventory.
signal inventory_changed();

## The size of this inventory in grid cells.
var size: Vector2i;

## Maps Vector2i to InventoryItemStack at that position
var _positionCache: Dictionary;

## Contains all items contained in this inventory.
var _items: Array[InventoryItemStack];

@warning_ignore("shadowed_variable")
func _init(size: Vector2i) -> void:
	self.size = size;

## Returns an array of all items in this inventory.[br]
## Duplicate before attempting to modify contents!
func get_all_items() -> Array[InventoryItemStack]:
	return _items;

## Returns a mapping of Vector2i's to InventoryItemStacks.[br]
## This dictionary maps position to the items at those positions. Position with no
## item on them are not present in the dictionary.[br]
## Duplicate before attempting to modify contents!
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

## Attempts to add item to given position. 
## Should only be used on areas that have been checked to be clear via
## can_fit_item.
func add_item_at_position(item_data: InventoryItem, count: int, pos: Vector2i, rotated: bool, instance_data: Dictionary = {}) -> void:
	var new_item := InventoryItemStack.new(
			item_data,
			min(item_data.stack_size, count),
			pos,
			rotated,
			instance_data
	);
	
	var corr_size: Vector2i = new_item.get_rotated_size();
	
	assert(can_fit_item(pos, corr_size), "Attempting to add item that cannot fit into inventory");
	
	_items.push_back(new_item);
	
	for x in range(pos.x, pos.x + corr_size.x):
		for y in range(pos.y, pos.y + corr_size.y):
			_positionCache[Vector2i(x, y)] = new_item;
	
	inventory_changed.emit();

## Returns the number of items with given id contained in inventory.
func get_item_count(id: String) -> int:
	var count: int = 0;
	
	for item in _find_stacks_by_id(id):
		count += item.count;
	
	return count;

## Removes givne item stack from the inventory. Should NOT be used on item stacks not present
## in inventory.
func take_item_stack(stack: InventoryItemStack) -> void:
	var idx: int = _items.find(stack);
	assert(idx != -1, "Item stack not present in this inventory!");
	
	_items.remove_at(idx);
	var corr_size: Vector2i = stack.get_rotated_size();
	
	for x in range(stack.position.x, stack.position.x + corr_size.x):
		for y in range(stack.position.y, stack.position.y + corr_size.y):
			_positionCache.erase(Vector2i(x, y));
	
	inventory_changed.emit();


## Removes given number of items from inventory, starting from the smallest stacks.
## If multiple stacks contain the same number of items
func take_item_count(id: String, count: int) -> bool:
	if get_item_count(id) < count:
		return false;
	
	var starting_count: int = count;
	
	var sort_func = func(a: InventoryItemStack, b: InventoryItemStack) -> bool:
		if a.count != b.count:
			return a.count < b.count;
		
		if a.position.y != b.position.y:
			return a.position.y < b.position.y;
		
		return a.position.x < b.position.x;
	
	var items: Array[InventoryItemStack] = _find_stacks_by_id(id);
	items.sort_custom(sort_func);
	
	for item in items:
		if item.count < count:
			count -= item.count;
			take_item_stack(item);
		else:
			item.count -= count;
			count = 0;
			break;
	
	if starting_count != count:
		inventory_changed.emit();
	
	return true;

## Checks whether item of given size could fit at given position.[br]
## ignoring_item can be used to ignore given single item from check.
## This is useful for drag and drop tests, where you want to ignore the dragged item.
func can_fit_item(item_pos: Vector2i, item_size: Vector2i, ignoring_item: InventoryItemStack = null) -> bool:
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

## Returns all inventory stacks with given id in a single array.
func _find_stacks_by_id(id: String) -> Array[InventoryItemStack]:
	var ret: Array[InventoryItemStack] = [];
	
	for item in _items:
		if item.data.id == id:
			ret.push_back(item);
	
	return ret;
