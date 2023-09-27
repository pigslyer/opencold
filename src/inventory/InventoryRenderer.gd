class_name InventoryRenderer;
extends Control

var _inventory: Inventory;

func _ready() -> void:
	mouse_exited.connect(_on_mouse_exited);

func set_inventory(inventory: Inventory) -> void:
	_inventory = inventory;
	inventory.inventory_changed.connect(queue_redraw);
	
	_clear_hover();
	queue_redraw();

func _on_mouse_exited():
	var drag_data = get_viewport().gui_get_drag_data();
	_clear_hover();
	
	if not drag_data is InventoryDraggedItem:
		return;
	
	drag_data = drag_data as InventoryDraggedItem;

func _get_drag_data(at_position: Vector2) -> Variant:
	if _inventory == null:
		return null;
	
	var render_data: RenderData = _get_render_data();
	var tile_pos := Vector2i((at_position - render_data.offset) / render_data.item_edge);
	var items: Dictionary = _inventory.get_all_items_by_position();
	var item_at_pos: InventoryItemStack = items.get(tile_pos);
	
	if item_at_pos == null:
		return null;
	
	var drag_data := InventoryDraggedItem.new(item_at_pos, _inventory, global_position + render_data.offset + Vector2(tile_pos) * render_data.item_edge);
	var preview := drag_data.generate_preview();
	
	set_drag_preview(preview);
	queue_redraw();
	return drag_data;

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if _inventory == null:
		return false;
	
	if not data is InventoryDraggedItem:
		return false;
	
	var render_data: RenderData = _get_render_data();
	
	if at_position.x < render_data.offset.x or at_position.y < render_data.offset.y:
		return false;
	
	if at_position.x > size.x - render_data.offset.x or at_position.y > size.y - render_data.offset.y:
		return false;
	
	var tile_pos := Vector2i((at_position - render_data.offset) / render_data.item_edge);
	
	return _inventory.can_fit_item(tile_pos, data.get_rotated_size(), data.stack);

func _drop_data(at_position: Vector2, data: Variant) -> void:
	queue_redraw();

func _gui_input(ev: InputEvent) -> void:
	if not ev is InputEventMouse:
		return
	
	var drag_data = get_viewport().gui_get_drag_data();
	
	var render_data: RenderData = _get_render_data();
	var tile_pos := Vector2i((ev.position - render_data.offset) / render_data.item_edge);
	
	if tile_pos.x < 0 or tile_pos.y < 0:
		_clear_hover();
		return;
	
	if tile_pos.x >= _inventory.size.x or tile_pos.y >= _inventory.size.y:
		_clear_hover();
		return;
	
	var hover_color: Color;
	var hover_outline: Color;
	
	if drag_data is InventoryDraggedItem:
		var correct_size: Vector2i = drag_data.get_rotated_size();
		
		if tile_pos.x + correct_size.x - 1 >= _inventory.size.x:
			_clear_hover();
			return;
		
		if tile_pos.y + correct_size.y - 1 >= _inventory.size.y:
			_clear_hover();
			return;
		
		drag_data.target_edge_length = render_data.item_edge;
		
		if _inventory.can_fit_item(tile_pos, drag_data.get_rotated_size(), drag_data.stack):
			hover_color = get_theme_color("hover_valid", "InventoryRenderer");
			hover_outline = get_theme_color("hover_valid_outline", "InventoryRenderer");
		else:
			hover_color = get_theme_color("hover_invalid", "InventoryRenderer");
			hover_outline = get_theme_color("hover_invalid_outline", "InventoryRenderer");
		
		_set_hover(tile_pos, drag_data.get_rotated_size(), hover_color, hover_outline);
	else:
		hover_color = get_theme_color("hover", "InventoryRenderer");
		hover_outline = get_theme_color("hover_outline", "InventoryRenderer");
		
		var item_at_pos: InventoryItemStack = _inventory.get_all_items_by_position().get(tile_pos);
		
		if item_at_pos == null:
			_set_hover(tile_pos, Vector2i.ONE, hover_color, hover_outline);
		else:
			_set_hover(item_at_pos.position, item_at_pos.get_rotated_size(), hover_color, hover_outline);
		

class HoverPreview extends ColorRect:
	const INTERP_SPEED: float = 0.3;
	const FADE_OUT_SPEED: float = 0.6;
	
	var _ref_rect: ReferenceRect;
	
	func _init(starting_position: Vector2, starting_size: Vector2) -> void:
		position = starting_position;
		size = starting_size;
		mouse_filter = MOUSE_FILTER_IGNORE;
		
		color = Color.TRANSPARENT;
		
		var reference_rect := ReferenceRect.new();
		add_child(reference_rect);
		reference_rect.set_anchors_preset(PRESET_FULL_RECT);
		reference_rect.editor_only = false;
		reference_rect.border_color = color;
		reference_rect.mouse_filter = MOUSE_FILTER_IGNORE;
		
		_ref_rect = reference_rect;
	
	func set_rect(local_pos: Vector2, local_size: Vector2) -> void:
		var tween := create_tween().set_parallel();
		
		tween.tween_property(self, "position", local_pos, INTERP_SPEED);
		tween.tween_property(self, "size", local_size, INTERP_SPEED);
	
	func set_hover(hover_color: Color, outline_color: Color) -> void:
		var tween := create_tween().set_parallel();
		
		tween.tween_property(self, "color", hover_color, INTERP_SPEED);
		tween.tween_property(_ref_rect, "border_color", outline_color, INTERP_SPEED);
	
	func hide_hover() -> void:
		var tween := create_tween();
		
		tween.tween_property(self, "modulate", Color(modulate, 0), FADE_OUT_SPEED);
		tween.tween_callback(queue_free);


var _active_hover: HoverPreview = null;

func _set_hover(hover_position: Vector2i, hover_size: Vector2i, hover_color: Color, outline_color: Color) -> void:
	var render_data: RenderData = _get_render_data();
	
	var hover_local_pos: Vector2 = render_data.offset + hover_position * render_data.item_edge;
	var hover_local_size: Vector2 = hover_size * render_data.item_edge;
	
	if _active_hover == null:
		_active_hover = HoverPreview.new(hover_local_pos, hover_local_size);
		add_child(_active_hover);
	else:
		_active_hover.set_rect(hover_local_pos, hover_local_size);
	
	_active_hover.set_hover(hover_color, outline_color);

func _clear_hover() -> void:
	if _active_hover == null:
		return;
	
	_active_hover.hide_hover();
	_active_hover = null;

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

func _draw_items() -> void:
	var render_data: RenderData = _get_render_data();
	
	var dragged_modulate: Color = get_theme_color("dragged_item_modulate", "InventoryRenderer");
	var drag_data = get_viewport().gui_get_drag_data();
	
	for item in _inventory.get_all_items():
		var is_being_dragged: bool = drag_data is InventoryDraggedItem and drag_data.stack == item;
		
		draw_set_transform(render_data.offset + (Vector2(item.position) + item.get_rotated_offset()) * render_data.item_edge, item.get_rotated_angle());
		draw_texture_rect(
				item.data.icon,
				Rect2(
					Vector2.ZERO, 
					Vector2(item.data.size) * render_data.item_edge), 
				false, # tile
				dragged_modulate if is_being_dragged else Color.WHITE
		);
	
	draw_set_transform(Vector2.ZERO);
	
	const MARGIN = Vector2(-8, -8);
	
	var font: Font = get_theme_default_font();
	var font_size: int = get_theme_default_font_size();
	
	for item in _inventory.get_all_items():
		var text_length: float = font.get_string_size(
				str(item.count), 
				HORIZONTAL_ALIGNMENT_LEFT, 
				-1, 
				font_size
		).x;
		
		draw_string_outline(
				font, 
				render_data.offset + (item.position + item.get_rotated_size()) * render_data.item_edge - Vector2(text_length, 0) + MARGIN, 
				str(item.count), 
				HORIZONTAL_ALIGNMENT_RIGHT, 
				-1, 
				font_size, 
				8, 
				Color.BLACK
		);
		
		draw_string(
				font, 
				render_data.offset + (item.position + item.get_rotated_size()) * render_data.item_edge - Vector2(text_length, 0) + MARGIN, 
				str(item.count), 
				HORIZONTAL_ALIGNMENT_RIGHT, 
				-1, 
				font_size
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
