class_name ScrollTerminalWindow
extends BaseTerminalWindow;

@export_multiline var text : String;
@export var has_back : bool = false;
@export var has_exit : bool = true;

const scroll_scene : PackedScene = preload("res://src/terminal/TerminalWindows/ScrollTerminalWindow/ScrollTerminalWindow.tscn");

func get_menu() -> Control:
	var scene_instance = scroll_scene.instantiate();
	scene_instance.get_scene(text, has_back, has_exit);
	return scene_instance;

