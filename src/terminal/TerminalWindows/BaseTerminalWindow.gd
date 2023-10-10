class_name BaseTerminalWindow
extends  Resource;

@export var button_text : String;

func get_menu() -> Control:
	push_error("BaseTerminalWindow doesn't return anything on its own.")
	return Control.new();
