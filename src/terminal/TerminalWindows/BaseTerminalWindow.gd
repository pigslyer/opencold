class_name BaseTerminalWindow
extends  Resource;

## Text shown on the button that leads to this window
@export var button_text : String;

func get_menu() -> Control:
	push_error("BaseTerminalWindow doesn't return anything on its own.")
	return Control.new();
