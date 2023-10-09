class_name PlayerEquipment;
extends Control
## Contains logic for handling and interfacing with every one of the player's
## equipment screens (inventory, cybernetics).

## Constant ID for the selected item.
const ID_SELECTION: String = "SELECTION"
const SELECTION_COLOR: Color = Color(1.0, 1.0, 1.0, 0.0);
const SELECTION_OUTLINE: Color = Color(1.0, 1.0, 1.0, 1.0);

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

func _on_inventory_inventory_event(item_stack: InventoryItemStack, cursur_position: Vector2i, ev: InputEvent) -> void:
	if ev is InputEventMouseButton && ev.pressed && ev.button_index == MOUSE_BUTTON_LEFT:
		if item_stack == null:
			_inventory_renderer.clear_selection(ID_SELECTION);
			select(null);
		else:
			var hovered_rect: Rect2i = Rect2i(item_stack.position, item_stack.get_rotated_size());
			_inventory_renderer.add_selection(ID_SELECTION, hovered_rect, SELECTION_COLOR, SELECTION_OUTLINE);
			select(item_stack);

## Make this item stack appear selected in the inventory. Highlights it, displays its name
## and description.
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
