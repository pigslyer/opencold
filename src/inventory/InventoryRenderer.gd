class_name InventoryRenderer;
extends Control

var _inventory: Inventory;

func set_inventory(inventory: Inventory) -> void:
	_inventory = inventory;
	inventory.connect("inventory_changed", Callable(self, "queue_redraw"));
	queue_redraw();


func _get_drag_data(at_position: Vector2) -> Variant:
	if _inventory == null:
		return null;
	
	var render_data: RenderData = _get_render_data();
	var tile_pos := Vector2i((at_position - render_data.offset) / render_data.item_edge);
	var items: Dictionary = _inventory.get_all_items_by_position();
	var item_at_pos: InventoryItemStack = items.get(tile_pos);
	
	if item_at_pos == null:
		return null;
	
	var drag_data := InventoryDraggedItem.new(item_at_pos, _inventory);
	var preview := InventoryDraggedItem.Preview.new(drag_data);
	
	set_drag_preview(preview);
	return drag_data;


func _draw() -> void:
	if _inventory == null:
		return;
	
	_draw_grid();
	_draw_items();

func _draw_grid() -> void:
	var inv_size := Vector2(_inventory.size);
	var render_data := _get_render_data();
	
	var style_empty: StyleBox = get_theme_stylebox("cell_empty", "InventoryRenderer");
	var style_filled: StyleBox = get_theme_stylebox("cell_filled", "InventoryRenderer");
	
	var items: Dictionary = _inventory.get_all_items_by_position();
	for x in range(0, inv_size.x):
		for y in range(0, inv_size.y):
			draw_style_box(
					style_filled if items.has(Vector2i(x, y)) else style_empty, 
					Rect2(
						render_data.offset + Vector2(x, y) * render_data.item_edge, 
						Vector2(render_data.item_edge, render_data.item_edge)
					)
			);


func _draw_items():
	var render_data := _get_render_data();
	
	for item in _inventory.get_all_items():
		draw_texture_rect(
				item.data.icon,
				Rect2(
					render_data.offset + Vector2(item.position) * render_data.item_edge, 
					Vector2(item.data.size) * render_data.item_edge), 
				false, # tile
				Color.WHITE, # modulate
				item.rotated # transpose
		);


func _get_render_data() -> RenderData:
	var inv_size := Vector2(_inventory.size);
	var tile_size: Vector2 = size / inv_size;
	var rect_edge: float = min(tile_size.x, tile_size.y);
	var offset: Vector2 = (size - inv_size * rect_edge) / 2;
	
	return RenderData.new(offset, rect_edge);

class RenderData extends RefCounted:
	var offset: Vector2;
	var item_edge: float;
	
	@warning_ignore("shadowed_variable")
	func _init(offset: Vector2, item_edge: float) -> void:
		self.offset = offset;
		self.item_edge = item_edge;
