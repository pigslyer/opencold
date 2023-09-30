class_name InventoryUsageData;
extends RefCounted
## Metadata processed by [InventoryItemBehaviour] as part of its callbacks.

## The player this item is equipped to.
var player: Player;

## The item's per instance data. May only be written to if this item's 
## [member InventoryItem.stack_size] is equal to 1.
var instance_data: Dictionary;

@warning_ignore("shadowed_variable")
func _init(player: Player, instance_data: Dictionary) -> void:
	self.player = player;
	self.instance_data = instance_data;
