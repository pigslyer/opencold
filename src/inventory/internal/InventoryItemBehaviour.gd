class_name InventoryItemBehaviour
extends RefCounted
## Determines the behaviour of an item when equipped/used. Should be dropped into
## an Inventory

func equip(_data: InventoryUsageData) -> void:
	pass

func update(_data: InventoryUsageData) -> void:
	pass

func unequip(_data: InventoryUsageData) -> void:
	pass
