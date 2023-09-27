@icon("res://src/assets/icon_item.svg")
class_name InventoryItem
extends Resource
## Represents serialized item data.
##
## Id should be a snake_case unchanging unique identifier.
## This allows for dynamically created items.

## Id by which [InventoryItem] object is queried
@export var id: String;

## The display name of this item.
@export var name: String;

## The display icon for this item.
@export var icon: Texture2D;

## The total number of items of this type you can hold in 1 stack.
@export var stack_size: int = 1;

## The size of this item in grid cells.
@export var size: Vector2i = Vector2.ONE;

@warning_ignore("shadowed_variable")
static func create_custom(id: String, name: String, icon: Texture2D, stack_size: int, size: Vector2i) -> InventoryItem:
	var item := InventoryItem.new();
	
	item.id = id;
	item.name = name;
	item.icon = icon;
	item.stack_size = stack_size;
	item.size = size;
	
	return item;
