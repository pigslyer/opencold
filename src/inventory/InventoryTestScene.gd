extends Control

func _ready():
	var inventory := Inventory.new(Vector2i(10, 10));
	inventory.add_item(preload("res://src/inventory/items/TestResource.tres"), 33);
	
	$InventoryRenderer.set_inventory(inventory);
	
	var inventory2 := Inventory.new(Vector2i(6, 6));
	inventory2.add_item(preload("res://src/inventory/items/TestResource.tres"), 4);
	
	$InventoryRenderer2.set_inventory(inventory2);
