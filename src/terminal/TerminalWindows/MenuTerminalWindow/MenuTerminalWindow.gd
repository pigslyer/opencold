class_name MenuTerminalWindow
extends BaseTerminalWindow;

@export_multiline var text : String;

## List of terminal windows that will be shown as buttons
@export var menus : Array[BaseTerminalWindow];
@export var has_back : bool = false;
@export var has_exit : bool = true;

const menu_scene : PackedScene = preload("res://src/terminal/TerminalWindows/MenuTerminalWindow/MenuTerminalWindow.tscn");

func get_menu() -> Control:
	var scene_instance = menu_scene.instantiate();
	scene_instance.get_scene(text, menus, has_back, has_exit);
	return scene_instance;

