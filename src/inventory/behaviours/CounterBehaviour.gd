extends InventoryItemBehaviour

func equip(data: InventoryUsageData) -> void:
	print("hi!");
	
	if not "my_data" in data.instance_data:
		data.instance_data["my_data"] = 0;

func update(data: InventoryUsageData) -> void:
	
	if Input.is_action_just_pressed("use_held"):
		data.instance_data["my_data"] += 1;
		print("new value is: ", data.instance_data["my_data"]);
	
func unequip(data: InventoryUsageData) -> void:
	print("bye!");
	print("data was: ", data.instance_data["my_data"]);
