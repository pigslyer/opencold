extends Control

var _inventory: Inventory;

func set_inventory(inventory: Inventory):
	inventory.connect("inventory_changed", Callable(self, "queue_redraw"));
	queue_redraw();

func _draw() -> void:
	if _inventory == null:
		return;
	
	_draw_grid();
	
	for item in _inventory.get_all_items():
		_draw_item(item);

func _draw_grid():
	var inv_size: Vector2i = _inventory.size;
	
	for x in range(0, size.x + 1):
		var cur_x: float = size.x / inv_size.x * x;
		draw_line(Vector2(cur_x, 0), Vector2(cur_x, size.y), Color.BLUE_VIOLET);
	
	for y in range(0, size.y + 1):
		var cur_y: float = size.y / inv_size.y * y;
		draw_line(Vector2(0, cur_y), Vector2(size.x, cur_y), Color.BLUE_VIOLET);

func _draw_item(item: InventoryItemStack):
	var inv_size: Vector2i = _inventory.size;
	var per_tile_size: Vector2 = size / Vector2(inv_size);
	
	var item_pos: Vector2 = per_tile_size * Vector2(item.position);
	var item_size: Vector2 = per_tile_size * Vector2(item.data.size);
	
	draw_texture_rect(item.data.icon, Rect2(item_pos, item_size), false, Color.WHITE, false);
