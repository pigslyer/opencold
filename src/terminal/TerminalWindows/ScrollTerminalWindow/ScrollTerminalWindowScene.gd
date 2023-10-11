extends VBoxContainer

signal previous_window;
signal exit_terminal;

func get_scene(
		text : String, 
		has_back : bool,
		has_exit : bool):
	$ScrollContainer/Label.text = text;
	
	if has_back:
		$BackButton.show();
		
	if has_exit:
		$ExitButton.show();
		


func _on_back_button_pressed():
	previous_window.emit();


func _on_exit_button_pressed():
	exit_terminal.emit();
