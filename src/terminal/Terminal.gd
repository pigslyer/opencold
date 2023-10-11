class_name Terminal
extends Control

@export var start_window : BaseTerminalWindow;

@onready  var content : MarginContainer = $ContentContainer;

var window_stack : Array[Node];

func open():
	self._add_window(start_window);

func _add_window(window : BaseTerminalWindow):
	var window_node = window.get_menu();
	if window_stack.size() > 0:
		window_stack[-1].visible = false;
	window_stack.push_back(window_node);
	content.add_child(window_node);
	
	window_node.connect("previous_window", _previous_window);
	window_node.connect("exit_terminal", queue_free);
	if (window_node.has_signal("next_window")):
		window_node.connect("next_window", _add_window);


func _previous_window():
	var close_window = window_stack.pop_back();
	close_window.queue_free();
	if window_stack.size() == 0:
		self.queue_free();
	else:
		window_stack[-1].visible = true;
