class_name PlayerEquipment;
extends Control

signal on_item_equipped(item: InventoryItemStack);

var _inventory: Inventory;
var _equipped: InventoryItemStack = null;
var _selected: InventoryItemStack = null;

@onready var _inventory_renderer: InventoryRenderer = $Inventory/VBox/HBox/Inventory;
@onready var _description: TextEdit = $Inventory/VBox/HBox/ItemDescription;
@onready var _equip_button: Button = $Inventory/VBox/Buttons/Equip;

func _ready() -> void:
	# replace with actual serialization and stuff
	_inventory = Inventory.new(Vector2i(10, 10));
	_inventory.add_item(load("res://src/inventory/items/TestResource.tres"), 4);
	_inventory_renderer.set_inventory(_inventory);

func get_inventory() -> Inventory:
	return _inventory;

func select(item: InventoryItemStack) -> void:
	if item == null:
		_description.clear();
	else:
		_description.text = item.data.name;
	
	_selected = item;
	_update_inventory_buttons();

func equip(item: InventoryItemStack) -> void:
	_equipped = item;
	on_item_equipped.emit(item);

func unequip() -> void:
	_equipped = null;
	on_item_equipped.emit(null);

func _on_equip_pressed() -> void:
	if _selected != _equipped:
		equip(_selected);
	else:
		unequip();
	
	_update_inventory_buttons();

func _update_inventory_buttons() -> void:
	_equip_button.text = "Equip" if _selected != _equipped else "Unequip";
	_equip_button.disabled = _selected == null;
