# Inventory system

When it comes to using the inventory system, one needs to be aware of 3 different classes.

## Inventory

The inventory classes provides low level access to inventory data itself, however it can be queried for item counts and instructed to add items.

## InventoryItem

This Resource represents the unique data that all inventory items should share - this is what would contain data about a gun, medkit, coin etc. It allows for defining the item's name, description, icon and even a custom behaviour script (currently only handles equipping and using equipped items).

InventoryItems contain an id field, and this is the only thing that needs to be unique in order for an item to be considered unique. This allows them to work without forcing all of them to be file system resources.

When creating new items for level design purposes, a decision has to be made as to whether or not the item should be stored in the filesystem as a resource or inlined into the level data. Generally, if something will only need to be spawned in that one specific container and we need never give it an overview (for example, a unique puzzle item would fit in this category), then inlining should be used. Otherwise, I recommend creating a a Resource, as this will let us reuse it, or just know where it is.

## InventoryItemBehaviour

This script represents a base type which should be used for scripting unique item behaviour. It contains a set of pure virtual functions with 1 parameter, a data class which allows for mutating the state of the player or item. This can currently only be used for equipping items, but we will expand it also handle at least item usage.

Note: This script should **NOT** contain any fields. The inventory makes no guarantee as to when a behaviour is instantiated or freed. Instance specific data should be stored in the data parameter's instance_data field.

Note: instance_data can **ONLY** be used if the InventoryItem's maximum stack size is 1, otherwise specific instances of an item cannot be tracked. If you still need to store data somewhere, an inventory_data dictionary should be implemented, which will be shared by the whole inventory/all items with a unique id.