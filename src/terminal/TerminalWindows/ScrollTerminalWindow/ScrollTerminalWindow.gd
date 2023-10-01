class_name ScrollTerminalWindow
extends BaseTerminalWindow;

@export_multiline var text : String;
@export var has_back : bool = true;
@export var has_exit : bool = false;

var label_scene : PackedScene = preload("res://src/terminal/TerminalWindows/ScrollTerminalWindow/ScrollTerminalWindow.tscn");
var button_scene : PackedScene = preload("res://src/terminal/TerminalWindows/TerminalButton.tscn");

signal previous_window;
signal exit_terminal;

func get_menu() -> Node:
	signals = [previous_window, exit_terminal];
	var scene_instance : Control = label_scene.instantiate();
	var label : Label = scene_instance.get_node("ScrollContainer/Label");
	label.text = text;
	
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
	#scene_instance.set_minimum_size(scene_instance.size.x,  scene_instance.size.y);
	return scene_instance;
