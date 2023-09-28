class_name InventoryUsageData;
extends RefCounted

var player: Player;
var instance_data: Dictionary;

@warning_ignore("shadowed_variable")
func _init(player: Player, instance_data: Dictionary) -> void:
	self.player = player;
	self.instance_data = instance_data;
