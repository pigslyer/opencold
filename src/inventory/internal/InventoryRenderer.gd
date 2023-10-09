class_name InventoryRenderer;
extends Control
## Renders a given inventory and handles basic input events - dragging and dropping items
## from and to itself and selecting items.

## Constant ID for the selected item.
const ID_SELECTION: String = "SELECTION"

## Emitted whenever a GUI event had occurred within the inventory and changed which grid cell was focused.
signal inventory_event(item_stack: InventoryItemStack, cursur_position: Vector2i);

## MOVE THIS OUT
## Emitted when an item has been selected (single clicked on)
signal item_selected(item: InventoryItemStack);

## Emitted when the contents of the contained inventory have changed.
signal inventory_content_changed();

## Possible alignments for the inventory's position.
enum Align {
	TOP_LEFT,
	CENTERED,
	BOTTOM_RIGHT,
};

@export var _grid_alignment: Align = Align.CENTERED;

## Whether or not to display the selection rectangle over clicked on items.
## Has no impact on selection logic.
## MOVE THIS OUT
@export var _display_selection: bool = true;

## Whether or not to display the hover effect over items.
@export var _display_hover: bool = true;

## The inventory being rendered.
var _inventory: Inventory;

## Whether or not the inventory is the source of any [InventoryDraggedItem]s.
## Important because it has to clear the dragged overlay off the dragged item.
var _rendering_any_drags: bool;

@onready var _hover := ItemSelection.new(self, _display_hover);

var _selections : Dictionary

func _ready() -> void:
	mouse_exited.connect(_on_mouse_exited);

func add_selection(id: String, area: Rect2i, fill_color: Color, outline_color: Color) -> bool:
	var flag: bool = false
	if !_selections.has(id):
		_selections[id] = ItemSelection.new(self, _display_selection)
		flag = true
	return _selections[id].set_selection(area.position, area.size, fill_color, outline_color) or flag

func clear_selection(id: String, instant: bool = false) -> bool:
	if _selections.has(id):
		_selections[id].clear(instant)
		return true
	return false

## Sets the rendered inventory.
func set_inventory(inventory: Inventory) -> void:
	if _inventory == inventory:
		return;
	
	if _inventory != null:
		_inventory.inventory_changed.disconnect(_on_inventory_changed);
	
	_inventory = inventory;
	_inventory.inventory_changed.connect(_on_inventory_changed);
	
	_hover.clear();
	clear_selection(ID_SELECTION);
	queue_redraw();

func _on_inventory_changed():
	queue_redraw();
	inventory_content_changed.emit();

func _on_mouse_exited():
	_hover.clear();


func _draw() -> void:
	if _inventory == null:
		return;
	
	_draw_grid();
	_draw_items();
	_draw_item_numbers();

## Draws all background styleboxes.
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

## Draws all item icons.
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

## Draws the item count text for all items with a stack size greater than 1.
func _draw_item_numbers():
	const MARGIN = Vector2(-8, -8);
	
	var render_data: RenderData = _get_render_data();
	
	var font: Font = get_theme_default_font();
	var font_size: int = get_theme_default_font_size();
	
	for item in _inventory.get_all_items():
		if item.data.stack_size == 1:
			continue;
		
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



func _get_drag_data(at_position: Vector2) -> Variant:
	if _inventory == null:
		return null;
	
	var render_data: RenderData = _get_render_data();
	var tile_pos: Vector2i = render_data.get_tile_pos(at_position);
	var items: Dictionary = _inventory.get_all_items_by_position();
	var item_at_pos: InventoryItemStack = items.get(tile_pos);
	
	if item_at_pos == null:
		return null;
	
	var drag_data := InventoryDraggedItem.new(item_at_pos, _inventory);
	var preview := drag_data.generate_preview();
	drag_data.target_edge_length = render_data.item_edge;
	
	_rendering_any_drags = true;
	set_drag_preview(preview);
	queue_redraw();
	clear_selection(ID_SELECTION);
	return drag_data;

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if _inventory == null:
		return false;
	
	if not data is InventoryDraggedItem:
		return false;
	
	var render_data: RenderData = _get_render_data();
	var tile_pos: Vector2i = render_data.get_tile_pos(at_position);
	
	return _inventory.can_fit_item(tile_pos, data.get_rotated_size(), data.stack);

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data = data as InventoryDraggedItem;
	
	data.source_inventory.take_item_stack(data.stack);
	
	var render_data: RenderData = _get_render_data();
	var tile_pos: Vector2i = render_data.get_tile_pos(at_position);
	
	_inventory.add_item_at_position(
			data.stack.data, 
			data.stack.count, 
			tile_pos, 
			data.is_rotated(), 
			data.stack.instance_data
	);
	
	queue_redraw();




func _gui_input(ev: InputEvent) -> void:
	if not ev is InputEventMouse:
		return
	
	var drag_data = get_viewport().gui_get_drag_data();
	
	var render_data: RenderData = _get_render_data();
	var tile_pos: Vector2i = render_data.get_tile_pos(ev.position);
	
	if tile_pos.x < 0 or tile_pos.y < 0:
		_hover.clear();
		return;
	
	if tile_pos.x >= _inventory.size.x or tile_pos.y >= _inventory.size.y:
		_hover.clear();
		return;
	
	var hover_color: Color;
	var hover_outline: Color;
	
	if drag_data is InventoryDraggedItem:
		drag_data.target_edge_length = render_data.item_edge;
		
		var correct_size: Vector2i = drag_data.get_rotated_size();
		
		if tile_pos.x + correct_size.x - 1 >= _inventory.size.x:
			_hover.clear();
			return;
		
		if tile_pos.y + correct_size.y - 1 >= _inventory.size.y:
			_hover.clear();
			return;
		
		if _inventory.can_fit_item(tile_pos, drag_data.get_rotated_size(), drag_data.stack):
			hover_color = get_theme_color("hover_valid", "InventoryRenderer");
			hover_outline = get_theme_color("hover_valid_outline", "InventoryRenderer");
		else:
			hover_color = get_theme_color("hover_invalid", "InventoryRenderer");
			hover_outline = get_theme_color("hover_invalid_outline", "InventoryRenderer");
		
		_hover.set_selection(tile_pos, drag_data.get_rotated_size(), hover_color, hover_outline);
	else:
		hover_color = get_theme_color("hover", "InventoryRenderer");
		hover_outline = get_theme_color("hover_outline", "InventoryRenderer");
		
		var item_at_pos: InventoryItemStack = _inventory.get_all_items_by_position().get(tile_pos);
		
		var hovered_rect: Rect2i;
		
		if item_at_pos == null:
			hovered_rect = Rect2i(tile_pos, Vector2i.ONE);
		else:
			hovered_rect = Rect2i(item_at_pos.position, item_at_pos.get_rotated_size());
		
		_hover.set_selection(hovered_rect.position, hovered_rect.size, hover_color, hover_outline);
		
		# we're trying to select something
		if ev is InputEventMouseButton && ev.pressed && ev.button_index == MOUSE_BUTTON_LEFT:
			if _selections.has(ID_SELECTION) and _selections[ID_SELECTION].get_rect() == Rect2i(hovered_rect.position, hovered_rect.size):
				clear_selection(ID_SELECTION);
			elif item_at_pos == null:
				clear_selection(ID_SELECTION);
			else:
				var color: Color = get_theme_color("selected_color", "InventoryRenderer");
				var outline: Color = get_theme_color("selected_outline" , "InventoryRenderer");
				
				add_selection(ID_SELECTION, hovered_rect, color, outline);
			
			if _selections.has(ID_SELECTION) and _selections[ID_SELECTION].get_rect() != ItemSelection.NO_RECT:
				item_selected.emit(item_at_pos);
			else:
				item_selected.emit(null);
	
	inventory_event.emit(_inventory.get_all_items_by_position().get(tile_pos), tile_pos)


func _process(_delta: float) -> void:
	if _rendering_any_drags and get_viewport().gui_get_drag_data() == null:
		clear_selection(ID_SELECTION, true);
		queue_redraw();
		_rendering_any_drags = false;


class ItemSelection extends RefCounted:
	const NO_RECT: Rect2i = Rect2i(Vector2.ZERO, Vector2.ZERO);
	
	var _inventory_renderer: InventoryRenderer;
	var _display: bool;
	
	var _selection_renderer: SelectionRenderer = null;
	var _current_rect: Rect2i;
	
	func _init(inventory_renderer: InventoryRenderer, display: bool) -> void:
		_inventory_renderer = inventory_renderer;
		_display = display;
	
	func set_selection(hover_position: Vector2i, hover_size: Vector2i, hover_color: Color, outline_color: Color) -> bool:
		var flag: bool = _current_rect.position != hover_position or _current_rect.size != hover_size;
		if not _display:
			_current_rect = Rect2i(hover_position, hover_size);
			return true;
		
		var render_data: RenderData = _inventory_renderer._get_render_data();
		
		var hover_local_pos: Vector2 = render_data.offset + hover_position * render_data.item_edge;
		var hover_local_size: Vector2 = hover_size * render_data.item_edge;
		
		if _selection_renderer == null:
			_selection_renderer = SelectionRenderer.new(hover_local_pos, hover_local_size);
			_inventory_renderer.add_child(_selection_renderer);
		else:
			_selection_renderer.set_rect(hover_local_pos, hover_local_size);
		
		_current_rect = Rect2i(hover_position, hover_size);
		return _selection_renderer.set_hover(hover_color, outline_color) or flag;
	
	func clear(instant: bool = false) -> void:
		if not _display:
			_current_rect = NO_RECT;
			return;
		
		if _selection_renderer == null:
			return;
		
		if instant:
			_selection_renderer.queue_free();
		else:
			_selection_renderer.hide_hover();
		
		_selection_renderer = null;
	
	func get_rect() -> Rect2i:
		if not _display:
			return _current_rect
		elif _selection_renderer == null:
			return NO_RECT;
		else:
			return _current_rect;
	
	class SelectionRenderer extends ColorRect:
		const INTERP_SPEED: float = 0.1;
		const FADE_OUT_SPEED: float = 0.5;
		
		var _target_rect: Rect2;
		var _target_color: Color;
		var _target_outline: Color;
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
			_target_rect = Rect2(starting_position, starting_size);
		
		func set_rect(local_pos: Vector2, local_size: Vector2) -> bool:
			if _target_rect.is_equal_approx(Rect2(local_pos, local_size)):
				return false;
			
			var tween := create_tween().set_parallel();
			
			tween.tween_property(self, "position", local_pos, INTERP_SPEED);
			tween.tween_property(self, "size", local_size, INTERP_SPEED);
			_target_rect = Rect2(local_pos, local_size);
			return true;
		
		func set_hover(hover_color: Color, outline_color: Color) -> bool:
			if _target_color.is_equal_approx(hover_color) and _target_outline.is_equal_approx(outline_color):
				return false;
			
			var tween := create_tween().set_parallel();
			
			tween.tween_property(self, "color", hover_color, INTERP_SPEED);
			tween.tween_property(_ref_rect, "border_color", outline_color, INTERP_SPEED);
			_target_color = hover_color;
			_target_outline = outline_color;
			return true;
		
		func hide_hover() -> void:
			var tween := create_tween();
			
			tween.tween_property(self, "modulate", Color(modulate, 0), FADE_OUT_SPEED);
			tween.tween_callback(queue_free);
	


func _get_render_data() -> RenderData:
	var inv_size := Vector2(_inventory.size);
	var tile_size: Vector2 = size / inv_size;
	var rect_edge: float = min(tile_size.x, tile_size.y);
	var offset: Vector2 = (size - inv_size * rect_edge);
	
	match _grid_alignment:
		Align.TOP_LEFT:
			return RenderData.new(Vector2.ZERO, rect_edge);
		Align.CENTERED:
			return RenderData.new(offset / 2, rect_edge);
		Align.BOTTOM_RIGHT:
			return RenderData.new(offset, rect_edge);
	
	return null;

class RenderData extends RefCounted:
	var offset: Vector2;
	var item_edge: float;
	
	@warning_ignore("shadowed_variable")
	func _init(offset: Vector2, item_edge: float) -> void:
		self.offset = offset;
		self.item_edge = item_edge;
	
	func get_tile_pos(local_position: Vector2) -> Vector2i:
		return Vector2i((local_position - offset) / item_edge);
