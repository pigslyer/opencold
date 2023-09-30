class_name PlayerEquipment;
extends Control
## Contains logic for handling and interfacing with every one of the player's
## equipment screens (inventory, cybernetics).

## Emitted when the player has chosen to equip something.
## Item is either the item stack that the player wishes to equip, or null if the player
## wants to unequip themselves.
signal on_item_equipped(item: InventoryItemStack);

## The internal inventory the player uses.
var _inventory: Inventory;

## The currently equipped item.
var _equipped: InventoryItemStack = null;

## The currently selected item.
var _selected: InventoryItemStack = null;

@onready var _inventory_renderer: InventoryRenderer = $Inventory/VBox/HBox/Inventory;
@onready var _description: TextEdit = $Inventory/VBox/HBox/ItemDescription;
@onready var _equip_button: Button = $Inventory/VBox/Buttons/Equip;

func _ready() -> void:
	# replace with actual serialization and stuff
	_inventory = Inventory.new(Vector2i(10, 10));
	_inventory.add_item(load("res://src/inventory/items/TestResource.tres"), 4);
	_inventory_renderer.set_inventory(_inventory);

## Returns this player's inventory.
func get_inventory() -> Inventory:
	return _inventory;

## Make this item stack appear selected in the inventory. Highlights it, displays its name
## and description.
## TODO: Expose inventory renderer's selection API and make this function select the given item.
func select(item: InventoryItemStack) -> void:
	if item == null:
		_description.clear();
	else:
		_description.text = item.data.name;
	
	_selected = item;
	_update_inventory_buttons();

## Sets this item stack as equipped in the player's inventory.
## TODO: Expose inventory renderer's ItemSelection API and make this function focus
## on the item with that.
func equip(item: InventoryItemStack) -> void:
	_equipped = item;
	on_item_equipped.emit(item);

## Unequips currently equipped item.
## TODO: See above.
func unequip() -> void:
	_equipped = null;
	on_item_equipped.emit(null);

func _on_equip_pressed() -> void:
	if _selected != _equipped:
		equip(_selected);
	else:
		unequip();
	
	_update_inventory_buttons();

## Updates all the buttons in the inventory section of the inventory.
## TODO: Add drop and use buttons.
func _update_inventory_buttons() -> void:
	_equip_button.text = "Equip" if _selected != _equipped else "Unequip";
	_equip_button.disabled = _selected == null;
