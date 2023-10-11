extends VBoxContainer

signal next_window(menu : MenuTerminalWindow);
signal previous_window;
signal exit_terminal;

func get_scene(
		text : String, 
		menus : Array[BaseTerminalWindow], 
		has_back : bool,
		has_exit : bool):
	$Label.text = text;
	
	# Make buttons
	for menu in menus:
		var butt = Button.new();
		$Label.add_sibling(butt);
		butt.text = menu.button_text;
		butt.pressed.connect(func():
			next_window.emit(menu);
		);
		
	if has_back:
		$BackButton.show();
		
	if has_exit:
		$ExitButton.show();
		


func _on_back_button_pressed():
	previous_window.emit();


func _on_exit_button_pressed():
	exit_terminal.emit();
