class_name InventoryDraggedItem;
extends RefCounted
## Metadata used for drags between inventories.

## Emitted when this item's rotated value changes.
signal dragged_item_rotated(rotated: bool);

## The stack this drag data is representing.
var stack: InventoryItemStack;

## The inventory the item stack originiates from.
var source_inventory: Inventory;

## Whether or not this item is rotated by 90°.
var _rotated: bool;

## The length of the edge of a 1x1 item for the last hovered inventory.
## Makes drops appear smoother..
var target_edge_length: float;

@warning_ignore("shadowed_variable")
func _init(item_stack: InventoryItemStack, source_inventory: Inventory) -> void:
	self.stack = item_stack;
	self.source_inventory = source_inventory;
	_rotated = item_stack.rotated;
	target_edge_length = 0;

func set_rotated(rotated: bool) -> void:
	if _rotated != rotated:
		_rotated = rotated;
		dragged_item_rotated.emit(_rotated);

func is_rotated() -> bool:
	return _rotated;

## Generates preview to be passed to set_drag_preview().
func generate_preview() -> Control:
	return Preview.new(self);

## Gets the absolute int size of this item, as affected by rotation.
func get_rotated_size() -> Vector2i:
	return stack.data.size if not _rotated else Vector2i(stack.data.size.y, stack.data.size.x);

## Gets the angle that this item should be rotated at, as affected by rotation.
func get_rotated_angle() -> float:
	return 0.0 if not _rotated else PI / 2

## Get the local offset that the item should be translated by when rotated, 
## if the pivot point is the top left of the sprite.
func get_rotated_offset() -> Vector2:
	return Vector2(get_rotated_size().x if _rotated else 0, 0);

class Preview extends Control:
	## The rate at which this item's edge length changes, in pixels per second.
	const EDGE_CORRECTION_RATE: float = 500;
	
	## The total time that rotation should take in seconds.
	const ROTATION_TIME: float = 0.15;
	
	## The drag data this preview is wrapping.
	var _wrapping_item: InventoryDraggedItem;
	
	## The item edge length in pixels.
	var _edge_length: float;
	
	
	## Whether or not this item is rotated. Used to ensure we don't tween when we don't have to.
	var _rotated: bool;
	
	## The current offset used to properly place the pivot.
	var _rotation_offset: Vector2;
	
	## The current angle of rotation in radians.
	var _rotation: float;
	
	func _init(wrapping_item: InventoryDraggedItem) -> void:
		_wrapping_item = wrapping_item;
		
		_edge_length = wrapping_item.target_edge_length;
		
		_rotated = wrapping_item._rotated;
		_rotation_offset = wrapping_item.get_rotated_offset();
		_rotation = wrapping_item.get_rotated_angle();
		
		wrapping_item.dragged_item_rotated.connect(_on_dragged_item_rotated);
	
	
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
			_wrapping_item.set_rotated(not _wrapping_item.is_rotated());
	
	
	func _on_dragged_item_rotated(rotated: bool) -> void:
		if rotated == _rotated:
			return;
		
		_rotated = rotated;
		
		var redraw = func(_discard):
			queue_redraw();
		
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC);
		tween.tween_property(self, "_rotation_offset", _wrapping_item.get_rotated_offset(), ROTATION_TIME);
		tween.tween_property(self, "_rotation", _wrapping_item.get_rotated_angle(), ROTATION_TIME);
		# hack to trigger queue redraws for the duration
		tween.tween_method(
			redraw, null, null, ROTATION_TIME
		);

