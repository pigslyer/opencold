class_name InventoryItemStack;
extends RefCounted
## Represents an "instance" of an InventoryItem within an inventory.

## This stack's associated item data.
var data: InventoryItem;

## The number of items in this stack. 
## This number is always in the range [1, [member InventoryItem.stack_size]).
var count: int:
	set = _set_item_count;

## This stack's position within an inventory.
var position: Vector2i;

## Whether or not this stack is rotated by 90°.
var rotated: bool;

@warning_ignore("shadowed_variable")
func _init(item_data: InventoryItem, item_count: int, position: Vector2i, rotated: bool):
	self.data = item_data;
	self.count = item_count;
	self.position = position;
	self.rotated = rotated;

func _set_item_count(new_count: int) -> void:
	assert(new_count >= 1 || new_count <= data.stack_size, "Attempted to set item count to value outside of item's range (%s -> [1, %s] for item with id %s))" % [new_count, data.stack_size, data.id]);
	count = new_count;
