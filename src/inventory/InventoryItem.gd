@icon("res://src/assets/icon_item.svg")
class_name InventoryItem
extends Resource
## Represents serialized item data.
##
## Id should be a snake_case unchanging unique identifier.
## This allows for dynamically created items.

## Id by which Inventory object is queried
@export var id: String;
## The display name of this item
@export var name: String;
## The display icon for this item
@export var icon: Texture2D;
## The total number of items of this type you can hold in 1 stack.
@export var stack_size: int = 1;
## The size of this item in grid cells.
@export var size: Vector2i = Vector2.ONE;

@warning_ignore("shadowed_variable")
func _init(id: String, name: String, icon: Texture2D) -> void:
	self.id = id;
	self.name = name;
	self.icon = icon;
