extends InventoryItemBehaviour

func equip(_data: InventoryUsageData) -> void:
	print("hi!");
	
	if not "my_data" in _data.instance_data:
		_data.instance_data["my_data"] = 0;

func update(_data: InventoryUsageData) -> void:
	
	if Input.is_action_just_pressed("use_held"):
		_data.instance_data["my_data"] += 1;
		print("new value is: ", _data.instance_data["my_data"]);
	
func unequip(_data: InventoryUsageData) -> void:
	print("bye!");
	print("data was: ", _data.instance_data["my_data"]);
