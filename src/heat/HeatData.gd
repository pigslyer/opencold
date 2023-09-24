class_name HeatData
extends RefCounted
## A helper class for passing heat alteration data to bodies.

## Value dictating what temperature the source is trying to get the target to be.
var target_internal_heat: float

## Value dictating the rate at which the target's temperature should be altered.
## A value of 1.0 would mean that the target would hit the target temperature in 1 second.
## A value of 0.1 would mean that it would take 10 seconds. Etc.
var heat_rate: float

## If this is set to true, the source is only trying to warm up the target, and never cool it down.
var warm_up_only: bool

func _init(m_heat: float = 30.0, r_heat: float = 0.1, warm_only: bool = false) -> void:
	target_internal_heat = m_heat
	heat_rate = r_heat
	warm_up_only = warm_only
