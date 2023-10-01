class_name Terminal
extends Node

@export var start_window : BaseTerminalWindow;

@onready  var content : MarginContainer = $ContentContainer;

var window_stack : Array;

func _ready():
	add_window(start_window);

func _process(delta):
	pass

func add_window(window : BaseTerminalWindow):
	var window_node = window.get_menu();
	connect_signals(window.signals);
	if window_stack.size() > 0:
		window_stack[-1].visible = false;
	window_stack.push_back(window_node);
	content.add_child(window_node);

func _previous_window():
	var close_window = window_stack.pop_back();
	content.remove_child(close_window);
	window_stack[-1].visible = true;

func connect_signals(window_signals : Array):
	for window_signal in window_signals:
		if window_signal.get_connections().size() > 0:
			continue;
			
		match window_signal.get_name():
			"next_window":
				window_signal.connect(add_window)
				
			"previous_window":
				window_signal.connect(_previous_window)
				
			"exit_terminal":
				window_signal.connect(queue_free)
