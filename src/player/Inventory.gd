extends Control

signal on_item_equipped(item);

@onready var _inventory: InventoryRenderer = $Inventory/VBox/HBox/Inventory;
@onready var _description: TextEdit = $Inventory/VBox/HBox/ItemDescription;
@onready var _equip_button: Button = $Inventory/VBox/Buttons/Equip;

var _equipped: InventoryItemStack = null;
var _selected: InventoryItemStack = null;

func _ready() -> void:
	# replace with actual serialization and stuff
	var inventory := Inventory.new(Vector2i(10, 10));
	_inventory.set_inventory(inventory);


func select(item: InventoryItemStack) -> void:
	_selected = item;
	
	if item == null:
		_description.clear();
		_equip_button.disabled = true;
		_equip_button.text = "Equip";
	else:
		_description.text = item.data.name;
		_equip_button.disabled = false;
		_equip_button.text = "Equip" if _selected != item else "Unequip";


func equip(item: InventoryItemStack) -> void:
	_equipped = item;
	on_item_equipped.emit(item);

func unequip() -> void:
	_equipped = null;
	on_item_equipped.emit(null);

func _on_equip_pressed() -> void:
	if _selected == _equipped:
		equip(_selected);
	else:
		unequip();
