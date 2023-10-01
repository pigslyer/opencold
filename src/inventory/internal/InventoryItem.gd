@tool

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

## A more verbose description of this item.
@export_multiline var description: String;

## The display icon for this item.
@export var icon: Texture2D;

## The total number of items of this type you can hold in 1 stack.
@export var stack_size: int = 1;

## The size of this item in grid cells.
@export var size: Vector2i = Vector2.ONE;

## The behaviour script to be used when this item is equipped/used.
var _behaviour: Script;

## Allows creation of custom items during the runtime.
@warning_ignore("shadowed_variable")
static func create_custom(id: String, name: String, description: String, icon: Texture2D, stack_size: int, size: Vector2i, behaviour: Script = null) -> InventoryItem:
	var item := InventoryItem.new();
	
	item.id = id;
	item.name = name;
	item.description = description;
	item.icon = icon;
	item.stack_size = stack_size;
	item.size = size;
	
	if behaviour != null:
		if _does_script_inherit_from_item_behaviour(behaviour):
			item.behaviour = behaviour;
		else:
			push_warning("Attempted to create custom item with behaviour which does not inherit form InventoryItemBehaviour! No behaviour will be used...");
	
	return item;

## Retrieves item behaviour instance if this item has one, null otherwise.
func get_behaviour_instance() -> InventoryItemBehaviour:
	if _behaviour == null:
		return null;
	
	var ref_counted := RefCounted.new();
	ref_counted.set_script(_behaviour);
	return ref_counted;

## Faking it so item behaviour can only be a valid script
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
		return _behaviour;
	
	return null;

func _set(property: StringName, value: Variant) -> bool:
	if property == "item_behaviour":
		if value is Script:
			if InventoryItem._does_script_inherit_from_item_behaviour(value):
				_behaviour = value;
			else:
				push_warning("Cannot use %s as item behaviour because it doesn't implement InventoryItemBehaviour!" % value.resource_path);
		else:
			_behaviour = null;
		
		return true;
	
	return false;

const _item_behaviour_script: Script = preload("res://src/inventory/internal/InventoryItemBehaviour.gd");

## Determines whether or not the given script is of type ItemBehaviour.
static func _does_script_inherit_from_item_behaviour(script: Script) -> bool:
	if script == _item_behaviour_script:
		return true;
	
	var base_script: Script = script.get_base_script();
	
	if base_script == null:
		return false;
	
	return _does_script_inherit_from_item_behaviour(base_script);
