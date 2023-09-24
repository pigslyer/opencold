class_name Inventory
extends RefCounted

signal inventory_changed();

var size: Vector2i;

func get_all_items() -> Array[InventoryItemStack]:
	return [];

## Attempts to add this number of item_data to this inventory without resorting.
## Returns the number of items that could NOT be added in.
func add_item(item_data: InventoryItem, count: int) -> int:
	return 0;

## Returns the number of items with given id contained in inventory.
func get_item_count(id: String) -> int:
	return 0;


func take_item_count(id: String, count: int) -> bool:
	return true;
