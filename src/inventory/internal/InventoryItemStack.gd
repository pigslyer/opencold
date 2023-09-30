class_name InventoryItemStack;
extends RefCounted
## Represents 1 or more "instances" of an InventoryItem within an inventory.

## This stack's associated item data.
var data: InventoryItem;

## The number of items in this stack. 
## This number is always in the range [1, [member InventoryItem.stack_size]).
var count: int:
	set = _set_item_count;

## This stack's position within an inventory.
var position: Vector2i;

## Whether or not this stack is rotated by 90°.
var rotated: bool = false;

## The per inventory item instance data. Should only be used on items with a stack count of 1.
var instance_data: Dictionary;

@warning_ignore("shadowed_variable")
func _init(item_data: InventoryItem, item_count: int, position: Vector2i, rotated: bool, instance_data: Dictionary) -> void:
	self.data = item_data;
	self.count = item_count;
	self.position = position;
	self.rotated = rotated;
	self.instance_data = instance_data;

func _set_item_count(new_count: int) -> void:
	assert(new_count >= 1 || new_count <= data.stack_size, "Attempted to set item count to value outside of item's range (%s -> [1, %s] for item with id %s))" % [new_count, data.stack_size, data.id]);
	count = new_count;

## Get absolute int size based on current rotation state.
func get_rotated_size() -> Vector2i:
	return data.size if not rotated else Vector2i(data.size.y, data.size.x);

## Get expected angle of rotation based on rotation state in radians.
func get_rotated_angle() -> float:
	return 0.0 if not rotated else PI / 2;

## Get expected local offset of item based on rotation state, assuming pivot point is
## in top left of sprite.
func get_rotated_offset() -> Vector2:
	return Vector2(get_rotated_size().x if rotated else 0, 0);
