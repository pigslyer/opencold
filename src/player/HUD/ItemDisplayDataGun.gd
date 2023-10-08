class_name ItemDisplayDataGun
extends ItemDisplayData

var ammo_left : int;
var mag_size : int;

@warning_ignore("shadowed_variable")
func _init(ammo_left: int, mag_size: int) -> void:
	self.ammo_left = ammo_left;
	self.mag_size = mag_size;
