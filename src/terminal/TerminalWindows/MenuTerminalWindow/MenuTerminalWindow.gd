class_name MenuTerminalWindow
extends BaseTerminalWindow;

@export_multiline var text : String;
@export var menus : Array[BaseTerminalWindow];
@export var has_back : bool = false;
@export var has_exit : bool = true;

var menu_scene : PackedScene = preload("res://src/terminal/TerminalWindows/MenuTerminalWindow/MenuTerminalWindow.tscn");
var button_scene : PackedScene = preload("res://src/terminal/TerminalWindows/TerminalButton.tscn");

signal next_window(menu : MenuTerminalWindow);
signal previous_window;
signal exit_terminal;

func get_menu() -> Node:
	signals = [next_window, previous_window, exit_terminal];
	var scene_instance = menu_scene.instantiate();
	var label = scene_instance.get_node("Label");
	label.text = text;
	
	# Make buttons
	for menu in menus:
		var button_instance = button_scene.instantiate();
		scene_instance.add_child(button_instance);
		button_instance.text = menu.button_text;
		button_instance.button_up.connect(emit_signal.bind("next_window", menu));
		
	if has_back:
		var button_instance = button_scene.instantiate();
		scene_instance.add_child(button_instance);
		button_instance.text = "Back";
		button_instance.button_up.connect(emit_signal.bind("previous_window"));
		
	if has_exit:
		var button_instance = button_scene.instantiate();
		scene_instance.add_child(button_instance);
		button_instance.text = "Exit";
		button_instance.button_up.connect(emit_signal.bind("exit_terminal"));
		
	return scene_instance;

