class_name InventoryDraggedItem;
extends TextureRect

var item_data: InventoryItemStack;
var source_inventory: Inventory;

var rotated: bool;

@warning_ignore("shadowed_variable")
func _init(item_data: InventoryItemStack, source_inventory: Inventory) -> void:
	self.item_data = item_data;
	self.source_inventory = source_inventory;
	self.rotated = item_data.rotated;

class Preview extends TextureRect:
	var _wrapping_item: InventoryDraggedItem;
	
	func _init(wrapping_item: InventoryDraggedItem) -> void:
		_wrapping_item = wrapping_item;
		texture = wrapping_item.item_data.data.icon;
		pivot_offset = texture.get_size() / 2;
	
	func set_rotated(rotated: bool) -> void:
		_wrapping_item.rotated = rotated;
		
		if rotated:
			rotation_degrees = 270;
		else:
			rotation_degrees = 0;
	
	func _input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton: 
			printt(ev.pressed, ev.button_index, MOUSE_BUTTON_RIGHT);
			if ev.pressed && ev.button_index == MOUSE_BUTTON_RIGHT:
				set_rotated(not _wrapping_item.rotated);
