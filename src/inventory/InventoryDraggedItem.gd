class_name InventoryDraggedItem;
extends RefCounted

var stack: InventoryItemStack;
var source_inventory: Inventory;

var rotated: bool;
var target_edge_length: float;

@warning_ignore("shadowed_variable")
func _init(item_stack: InventoryItemStack, source_inventory: Inventory) -> void:
	self.stack = item_stack;
	self.source_inventory = source_inventory;
	self.rotated = item_stack.rotated;
	target_edge_length = 0;

func generate_preview() -> Control:
	return Preview.new(self);

func get_rotated_size() -> Vector2i:
	return stack.data.size if not rotated else Vector2i(stack.data.size.y, stack.data.size.x);

func get_rotated_angle() -> float:
	return 0.0 if not rotated else PI / 2

func get_rotated_offset() -> Vector2:
	return Vector2(get_rotated_size().x if rotated else 0, 0);

class Preview extends Control:
	const FOLLOW_SPEED: float = 1600;
	const EDGE_CORRECTION_RATE: float = 500;
	
	const ROTATION_TIME: float = 0.15;
	
	var _wrapping_item: InventoryDraggedItem;
	
	var _rotation_offset: Vector2;
	
	var _edge_length: float;
	var _rotation: float;
	
	func _init(wrapping_item: InventoryDraggedItem) -> void:
		_wrapping_item = wrapping_item;
		
		_rotation_offset = wrapping_item.get_rotated_offset();
		
		_edge_length = wrapping_item.target_edge_length;
		_rotation = wrapping_item.get_rotated_angle();
	
	
	func _process(delta: float) -> void:
		if not is_equal_approx(_edge_length, _wrapping_item.target_edge_length):
			_edge_length = move_toward(_edge_length, _wrapping_item.target_edge_length, EDGE_CORRECTION_RATE * delta);
			queue_redraw();
		
	
	func _draw() -> void:
		var item_size: Vector2 = Vector2(_wrapping_item.stack.data.size) * _edge_length;
		var rotation_offset: Vector2 = _rotation_offset * _edge_length;
		
		draw_set_transform(rotation_offset, _rotation);
		draw_texture_rect(
				_wrapping_item.stack.data.icon,
				Rect2(
					Vector2.ZERO,
					item_size),
				false,
		);
		draw_set_transform(Vector2.ZERO, 0);
		
		var rotated_item_size: Vector2 = item_size.rotated(_rotation);
		
		if _wrapping_item.stack.data.stack_size == 1:
			return;
		
		const COUNT_FONT_SIZE: int = 20;
		const MARGIN = Vector2(-8, -8);
		
		var font: Font = get_theme_default_font();
		var font_size: float = get_theme_default_font_size();
		var text_length: float = font.get_string_size(str(_wrapping_item.stack.count)).x * COUNT_FONT_SIZE / font_size;
		draw_string_outline(
			font, 
			rotated_item_size + 2 * rotation_offset - Vector2(text_length, 0) + MARGIN, 
			str(_wrapping_item.stack.count), 
			HORIZONTAL_ALIGNMENT_RIGHT, 
			-1, 
			COUNT_FONT_SIZE, 
			8, 
			Color.BLACK
		);
		
		draw_string(
			font, 
			rotated_item_size + 2 * rotation_offset - Vector2(text_length, 0) + MARGIN, 
			str(_wrapping_item.stack.count), 
			HORIZONTAL_ALIGNMENT_RIGHT, 
			-1, 
			COUNT_FONT_SIZE
		);
	
	
	func _input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton && ev.pressed && ev.button_index == MOUSE_BUTTON_RIGHT:
			_rotate();
		
		if ev is InputEventMouseMotion:
			queue_redraw();
	
	
	func _rotate() -> void:
		_wrapping_item.rotated = not _wrapping_item.rotated;
		
		var redraw = func(_discard):
			queue_redraw();
		
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
		tween.tween_property(self, "_rotation_offset", _wrapping_item.get_rotated_offset(), ROTATION_TIME);
		tween.tween_property(self, "_rotation", _wrapping_item.get_rotated_angle(), ROTATION_TIME);
		tween.tween_method(
			redraw, null, null, ROTATION_TIME
		);

