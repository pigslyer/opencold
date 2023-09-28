@tool

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

var behaviour: Script;

@warning_ignore("shadowed_variable")
static func create_custom(id: String, name: String, icon: Texture2D, stack_size: int, size: Vector2i, behaviour: Script = null) -> InventoryItem:
	var item := InventoryItem.new();
	
	item.id = id;
	item.name = name;
	item.icon = icon;
	item.stack_size = stack_size;
	item.size = size;
	item.behaviour = behaviour;
	
	return item;



func _get_property_list() -> Array[Dictionary]:
	return [
		{
			"name" : "item_behaviour",
			"class_name": "Script",
			"type" : TYPE_OBJECT,
			"usage" : PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR,
		},
	];

func _get(property: StringName) -> Variant:
	if property == "item_behaviour":
		return behaviour;
	
	return null;

func _set(property: StringName, value: Variant) -> bool:
	if property == "item_behaviour":
		if value is Script and _does_type_inherit_from_item_behaviour(value):
			behaviour = value;
		else:
			behaviour = null;
		
		return true;
	
	return false;

const _item_behaviour_script: Script = preload("res://src/inventory/InventoryItemBehaviour.gd");

func _does_type_inherit_from_item_behaviour(script: Script) -> bool:
	if script == _item_behaviour_script:
		return true;
	
	var base_script: Script = script.get_base_script();
	
	if base_script == null:
		return false;
	
	return _does_type_inherit_from_item_behaviour(base_script);
